### Subnet 생성 ###
### Public Subnet - Bastion Subnet 생성 ###
resource "ncloud_subnet" "public-bastion-subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = cidrsubnet(ncloud_vpc.vpc.ipv4_cidr_block, 8, 0)
  zone           = var.zone_1
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "${var.name_customer}-bastion-kr1"
  usage_type     = "GEN"
}

### Private Subnet - Web Subnet 생성 ###
resource "ncloud_subnet" "private-web-subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = cidrsubnet(ncloud_vpc.vpc.ipv4_cidr_block, 8, 1)
  zone           = var.zone_1
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "${var.name_customer}-web-kr1"
  usage_type     = "GEN"
}

### Private Subnet - Was Subnet 생성 ###
resource "ncloud_subnet" "private-was-subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = cidrsubnet(ncloud_vpc.vpc.ipv4_cidr_block, 8, 7)
  zone           = var.zone_1
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "${var.name_customer}-was-kr1"
  usage_type     = "GEN"
}

### Private Subnet - DB Subnet 생성 ###
resource "ncloud_subnet" "private-db-subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = cidrsubnet(ncloud_vpc.vpc.ipv4_cidr_block, 8, 5)
  zone           = var.zone_1
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "${var.name_customer}-db-kr1"
  usage_type     = "GEN"
}

### Nat Subnet - Nat Subnet 생성 ###
resource "ncloud_subnet" "public-nat-subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = cidrsubnet(ncloud_vpc.vpc.ipv4_cidr_block, 8, 3)
  zone           = var.zone_1
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "${var.name_customer}-nat-kr1"
  usage_type     = "NATGW"
}


### Load Balancer Subnet - ALB Subnet 생성 ###
resource "ncloud_subnet" "alb-subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = cidrsubnet(ncloud_vpc.vpc.ipv4_cidr_block, 8, 4)
  zone           = var.zone_1
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "${var.name_customer}-was-alb"
  usage_type     = "LOADB"
}

