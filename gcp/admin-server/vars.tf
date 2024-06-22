variable "project" {
  type        = string
  description = "The ID of the admin server's project"
}

variable "zone" {
  type        = string
  description = "The admin server's zone"
}

variable "instance_type" {
  type        = string
  description = "The admin server's instance type"
  default     = "n1-standard-1"
}

variable "boot_image" {
  type        = string
  description = "The admin server's boot image"
  default     = "centos-cloud/centos-stream-9"
}

variable "package_url" {
  type        = string
  description = "URL of the Project N package to install on launch"
}

variable "ssh_username" {
  type        = string
  description = "Name of the SSH user"
  default     = "projectn"
}
