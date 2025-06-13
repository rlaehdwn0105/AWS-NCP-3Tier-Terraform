### Key Pair ###
resource "ncloud_login_key" "loginkey" {
  key_name = "${var.name_customer}-key"
}

### Server Information ### 
data "ncloud_server_image" "server_image" {
  filter {
    name   = "product_name"
    values = ["ubuntu-20.04"]
  }
}

data "ncloud_server_product" "product" {
  server_image_product_code = data.ncloud_server_image.server_image.id

  filter {
    name   = "product_code"
    values = ["SSD"]
    regex  = true
  }
  filter {
    name   = "cpu_count"
    values = ["2"]
  }
  filter {
    name   = "memory_size"
    values = ["4GB"]
  }
  filter {
    name   = "product_type"
    values = ["HICPU"]
  }
}
### NIC ###
### NIC Bastion ###
resource "ncloud_network_interface" "nic_bastion" {
  name                  = "${var.name_customer}-bastion-nic"
  subnet_no             = ncloud_subnet.public-bastion-subnet.id
  access_control_groups = [ncloud_access_control_group.public-acg.id]
}
### NIC Web ###
resource "ncloud_network_interface" "nic_web" {
  name                  = "${var.name_customer}-web-nic"
  subnet_no             = ncloud_subnet.public-bastion-subnet.id
  access_control_groups = [ncloud_access_control_group.private-acg.id]
}
### NIC Was ### 
resource "ncloud_network_interface" "nic_was" {
  name                  = "${var.name_customer}-was-nic"
  subnet_no             = ncloud_subnet.public-bastion-subnet.id
  access_control_groups = [ncloud_access_control_group.private-acg.id]
}
### Public IP ###
resource "ncloud_public_ip" "public_ip" {
  server_instance_no = ncloud_server.bastion-server.id
  description        = "for ${ncloud_server.bastion-server.name} public ip"
}

### Bastion Server ###  
resource "ncloud_server" "bastion-server" {
  subnet_no                 = ncloud_subnet.public-bastion-subnet.id
  name                      = "${var.name_customer}-bastion-kr1"
  server_image_product_code = data.ncloud_server_image.server_image.id
  server_product_code       = data.ncloud_server_product.product.id
  login_key_name            = ncloud_login_key.loginkey.key_name
}

### Web Server ###  
resource "ncloud_server" "Web-server" {
  subnet_no                 = ncloud_subnet.private-web-subnet.id
  name                      = "${var.name_customer}-web-kr1"
  server_image_product_code = data.ncloud_server_image.server_image.id
  server_product_code       = data.ncloud_server_product.product.id
  login_key_name            = ncloud_login_key.loginkey.key_name
}

### Was Server ###  
resource "ncloud_server" "Was-server" {
  subnet_no                 = ncloud_subnet.private-was-subnet.id
  name                      = "${var.name_customer}-was-kr1"
  server_image_product_code = data.ncloud_server_image.server_image.id
  server_product_code       = data.ncloud_server_product.product.id
  login_key_name            = ncloud_login_key.loginkey.key_name
}

/*
### Export Root Password ###
data "ncloud_root_password" "default" {
  server_instance_no = ncloud_server.bastion-server.instance_no 
  private_key = ncloud_login_key.loginkey.private_key 
}

resource "local_file" "bastion_svr_root_pw" {
  filename = "${ncloud_server.bastion_server.name}-root_password.txt"
  content = "${ncloud_server.bastion_server.name} => ${data.ncloud_root_password.default.root_password}"
}
*/