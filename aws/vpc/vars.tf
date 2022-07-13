variable "vpc_cidr" {
  type    = string
  default = "132.0.0.0/16"
}
resource "random_id" "vpc_suffix" {
  byte_length = 2
}
locals {
  prefix = "project-n-${random_id.vpc_suffix.hex}"
}
