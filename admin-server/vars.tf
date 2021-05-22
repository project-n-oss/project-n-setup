variable "key_name" {
  type = string
}
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
variable "crunch_mode" {
  type = bool
}