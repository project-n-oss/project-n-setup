variable "region" {
  type        = string
  description = "AWS Region where the admin server will be created"
}

variable "key_name" {
  type        = string
  description = "AWS EC2 key pair to use When connecting to the admin server over SSH"
}

variable "package_url" {
  type        = string
  description = "URL of the Project N package to install on launch"
}

variable "ssh_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allow SSH access from the specified CIDR ranges. Defaults to 0.0.0.0/0, allowing access from anywhere."
}

variable "manage_vpc" {
  type        = bool
  default     = true
  description = "Project N can automatically configure a VPC to launch into, but this requires elevated permissions. Set to false to disable these permissions if you would rather manually manage VPC resources"
}

variable "profile" {
  type        = string
  default     = "default"
  description = "AWS profile to use for deployment"
}
