variable "package_url" {
  type = string
}
variable "ssh_access_cidrs" {
  type = list(string)
}
variable "manage_vpc" {
  type = bool
}
variable "region" {
  type = string
}
variable "profile" {
  type = string
}
variable "crunch_mode" {
  type = bool
}
variable "ssh_key_name" {
  type = string
}
variable "vpc_id" {
  type    = string
  default = ""
}
variable "subnet_id" {
  type    = string
  default = null
}
variable "iam_role" {
  type    = string
  default = null
}
variable "default_tag" {
  type        = string
  default     = "Project N Infrastructure"
  description = "Default tag for infrastructure created by terraform on AWS."
}
