# vpc 에서 데이터 끌어오기
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
  path = "../network/terraform.tfstate"
 }
}
# db에서 데이터 끌어오기
data "terraform_remote_state" "db" {
  backend = "local"
  config = {
  path = "../db/terraform.tfstate"
  }
}
resource "aws_instance" "bation" {
  ami = "ami-035da6a0773842f64"
  instance_type = "t2.micro"
  subnet_id = data.terraform_remote_state.network.outputs.dj_pub_1
  security_groups = [aws_security_group.dj-sg.id]
  associate_public_ip_address = "true"
  tags = var.my-tags
  key_name = aws_key_pair.deployer.key_name
}
### key pair 생성 ###
resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = file("~/.ssh/testkey.pub") 
}
resource "aws_key_pair" "prikey" {
  key_name = "prikey-key"
  public_key = file("~/.ssh/id_rsa.pub") 
}
############# EIP 생성 ###############
resource "aws_eip" "lb" {
  domain = "vpc"
}

####### 보안 그룹 생성 ########
resource "aws_security_group" "dj-sg" {
  name        = "dj-sg"
  description = "Allow 80/8080/22/tcp inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.dj_vpc_id

  ingress {
    description      = "80/tcp from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "8080/tcp from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "22/tcp from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
  from_port = -1
  to_port = -1
  protocol = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow DB(3306)"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dj-sg"
  }
}
# 시작 템플릿 
resource "aws_launch_configuration" "dj-conf" {
  name          = "dj-conf"
  image_id      = "ami-035da6a0773842f64"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.dj-sg.id]
  key_name = aws_key_pair.prikey.key_name
  
  user_data = templatefile("userdata.sh", {
  db_address = data.terraform_remote_state.db.outputs.DB_dns
  })
}

########## Target Group 생성 ##########
resource "aws_lb_target_group" "dj-tg-gr" {
  name     = "dj-tg-gr"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.dj_vpc_id
}
########## Auto Scaling Group 생성 ##########
resource "aws_autoscaling_group" "dj-asg" {
  name = "dj-asg"
  max_size           = 5
  min_size           = 2
  launch_configuration = aws_launch_configuration.dj-conf.name
  vpc_zone_identifier = [
  data.terraform_remote_state.network.outputs.dj_pri_1, 
  data.terraform_remote_state.network.outputs.dj_pri_2
  ]

  target_group_arns = [aws_lb_target_group.dj-tg-gr.arn]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "dj-asg"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
############ ALB Security Group 생성 #############
resource "aws_security_group" "djalb-sg" {
  name        = "djalb-sg"
  description = "Allow 80/8080/22/tcp inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.dj_vpc_id

  ingress {
    description      = "80/tcp from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "8080/tcp from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "djalb-sg"
  }
}
######## LB 생성 #########
resource "aws_lb" "dj-lb" {
  name               = "dj-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.djalb-sg.id]
  subnets            = [
    data.terraform_remote_state.network.outputs.dj_pub_1, 
    data.terraform_remote_state.network.outputs.dj_pub_2
    ]
  
  tags = {
    Environment = "dev"
  }
}
####### LB 리스너 구성 #######
resource "aws_lb_listener" "dj-listner" {
  load_balancer_arn = aws_lb.dj-lb.arn
  port              =  80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 not found."
      status_code  = "404"
    }
  }
}
######## LB 규칙 구성 ########
resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.dj-listner.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dj-tg-gr.arn
  }
}

