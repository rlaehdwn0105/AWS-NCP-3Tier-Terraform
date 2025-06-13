#### VPC 생성 ####
resource "ncloud_vpc" "vpc" {
  name            = "${var.name_customer}-vpc"
  ipv4_cidr_block = var.vpc_cidr
}
