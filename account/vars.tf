variable "account_name" {
  type = string
}
variable "account_email" {
  type = string
}
variable "organizational_iam_role_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet_cidrs" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}


