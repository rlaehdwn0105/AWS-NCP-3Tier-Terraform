### Cloud DB for MySQL ### 
resource "ncloud_mysql" "mysql" {
  subnet_no          = ncloud_subnet.private-db-subnet.id
  service_name       = "${var.name_customer}-mysql"
  server_name_prefix = "${var.name_customer}-mysql"
  user_name          = var.db_username
  user_password      = var.db_password
  host_ip            = "%"
  database_name      = "${var.name_customer}-mysql"
  is_ha              = false
  #image_product_code = data.ncloud_mysql_image_products.image.id
 # product_code       = data.ncloud_mysql_products.product.id
}

/*
data "ncloud_mysql_image_products" "image" {
  filter {
    name = "product_code"
    values = ["SW.VDBAS.DBAAS.LNX64.CNTOS.0708.MYSQL.8021.B050"]
  }
}

data "ncloud_mysql_products" "product" {
  image_product_code = data.ncloud_mysql_image_products.image.id

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
*/