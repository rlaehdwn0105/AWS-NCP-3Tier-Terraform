data "terraform_remote_state" "network" {
  backend = "local"
  
  config = {
    path = "../network/terraform.tfstate"
  }
}

# Create RDS Security Group
resource "aws_security_group" "dj-dbsg" {
  name = "dj-dbsg"
  vpc_id = data.terraform_remote_state.network.outputs.dj_vpc_id
  
  ingress {
  description = "Allow DB(3306)"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "dj-dbsg"
  }
}
# Create DB Subnet Group
resource "aws_db_subnet_group" "dj-subnetgr" {
  name = "dj-subnetgr"

  subnet_ids = [
    data.terraform_remote_state.network.outputs.dj_pri_3,
    data.terraform_remote_state.network.outputs.dj_pri_4
    ]

  tags = {
    Name = "dj-subnetgr"
  }
}
########### RDS Instance 생성 ############
resource "aws_rds_cluster_instance" "dj-rds-cluster_instance" {
  count = 2
  identifier = "aurora-cluster-demo-${count.index}"
  cluster_identifier = aws_rds_cluster.dj-rds-cluster.id
  instance_class = "db.t3.small"
  engine = aws_rds_cluster.dj-rds-cluster.engine
  engine_version = aws_rds_cluster.dj-rds-cluster.engine_version
}
############ RDS Cluster 구성 ############
resource "aws_rds_cluster" "dj-rds-cluster" {
  db_subnet_group_name = aws_db_subnet_group.dj-subnetgr.name
  cluster_identifier = "aurora-cluster-dj"
  engine = "aurora-mysql"
  engine_mode = "provisioned"
  engine_version = "5.7.mysql_aurora.2.07.9"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  database_name = "djdb"
  master_username = var.database_user
  master_password = var.database_password
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.dj-dbsg.id]
  port = 3306
}