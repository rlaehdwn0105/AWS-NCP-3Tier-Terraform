### Public ACG ### 
resource "ncloud_access_control_group" "public-acg" {
  name        = "${var.name_customer}-public-acg"
  description = "public-acg"
  vpc_no      = ncloud_vpc.vpc.id
}

resource "ncloud_access_control_group_rule" "public-acg-rule" {
  access_control_group_no = ncloud_access_control_group.public-acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "22"
    description = "accept 22 port"
  }

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "80"
    description = "accept 80 port"
  }

  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "accept 1-65535 port"
  }
}
### Private ACG ### 
resource "ncloud_access_control_group" "private-acg" {
  name        = "${var.name_customer}-private-acg"
  description = "private-acg"
  vpc_no      = ncloud_vpc.vpc.id
}

resource "ncloud_access_control_group_rule" "private-acg-rule" {
  access_control_group_no = ncloud_access_control_group.private-acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = var.vpc_cidr
    port_range  = "1-65535"
    description = "accept 1-65535 port"
  }

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "80"
    description = "accept 80 port"
  }

  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "accept 1-65535 port"
  }
}