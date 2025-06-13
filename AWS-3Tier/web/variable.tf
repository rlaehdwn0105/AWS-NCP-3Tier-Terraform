variable "my-tags" {
  description = "My tags"
  type = map(string) 
  default = {
    Name = "pj_instance"
  }
}