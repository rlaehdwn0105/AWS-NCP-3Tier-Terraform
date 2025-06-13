### ALB ###
resource "ncloud_lb" "alb" {
  name           = "${var.name_customer}-was-alb"
  network_type   = "PUBLIC"
  type           = "APPLICATION"
  subnet_no_list = [ncloud_subnet.alb-subnet.id]
}

### ALB Listener ###
resource "ncloud_lb_listener" "alb_listener" {
  load_balancer_no = ncloud_lb.alb.load_balancer_no
  protocol         = "HTTP"
  port             = 80
  target_group_no  = ncloud_lb_target_group.alb-target.target_group_no
}

### ALB Target_group & attachment ###
resource "ncloud_lb_target_group" "alb-target" {
  name        = "${var.name_customer}-was-alb-tg"
  vpc_no      = ncloud_vpc.vpc.id
  protocol    = "HTTP"
  target_type = "VSVR"
  port        = 80
  description = "ALB-Was-target-group"
  health_check {
    protocol       = "HTTP"
    http_method    = "GET"
    port           = 80
    url_path       = "/"
    cycle          = 60
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

resource "ncloud_lb_target_group_attachment" "attachment" {
  target_group_no = ncloud_lb_target_group.alb-target.target_group_no
  target_no_list  = [ncloud_server.Was-server.instance_no]
}