### NAT Gateway ###
resource "ncloud_nat_gateway" "nat_gateway" {
  name      = "${var.name_customer}-nat-kr1"
  subnet_no = ncloud_subnet.public-nat-subnet.id
  vpc_no    = ncloud_vpc.vpc.id
  zone      = var.zone_1
}

resource "ncloud_route" "nat" {
  route_table_no         = ncloud_vpc.vpc.default_private_route_table_no
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW"
  target_name            = ncloud_nat_gateway.nat_gateway.name
  target_no              = ncloud_nat_gateway.nat_gateway.id
}


