### VPC ###
variable "name_customer" {
  description = "customer-Name"
  type        = string
  default     = "kdj"
}
variable "vpc_cidr" {
  description = "VPC-cidr"
  type        = string
  default     = "10.16.0.0/16"
}
### Subnet ###
### availability_zone ###
### zone ### 
variable "zone_1" {
  description = "availability_zone-1"
  type        = string
  default     = "KR-1"
}
variable "zone_2" {
  description = "availability_zone-2"
  type        = string
  default     = "KR-2"
}

### DB for MySQL
variable "db_password" {
  description = "db_password"
  type        = string
  default     = "brickmate1!"
}
variable "db_username" {
  description = "db_username"
  type        = string
  default     = "brickmate"
}

### module id ### 
variable "region" {
  default = "KR"
}
variable "access_key" {
  default = ""
}
variable "secret_key" {
  default = ""
}
