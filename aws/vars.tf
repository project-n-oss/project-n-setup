variable "crunch_mode" {
  type        = bool
  default     = false
  description = "Prepare to crunch data, rather than just estimating savings"
}

variable "region" {
  type        = string
  description = "AWS Region where the admin server will be created"
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

variable "ssh_key_name" {
  type        = string
  default     = ""
  description = "Name of the key pair to use with the admin server. If not set, a new key pair is created."
}

// Crunch mode only (not estimate savings)

variable "account_name" {
  type        = string
  default     = "Project N"
  description = "If create_account is true, a new AWS account with this name will be created and Project N Bolt will be deployed from it."
}

variable "create_account" {
  type        = bool
  default     = true
  description = "Whether to create an account from which to deploy Project N Bolt."
}

variable "account_email" {
  type        = string
  default     = ""
  description = "Email of the AWS account to deploy Project N Bolt from. If create_account is true, a new account with this email will be created; in that case this must be an email you have access to."
}

variable "default_tag" {
  type        = string
  default     = "Project N Infrastructure"
  description = "Default tag for infrastructure created by terraform on AWS."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "ID of the VPC of the applications you wish to connect to Bolt"
}
variable "admin_server_subnet_id" {
  type        = string
  default     = null
  description = "ID of the subnet to deploy the admin server into"
}
variable "subnet_cidrs" {
  type        = list(string)
  default     = ["", ""]
  description = "CIDR Ranges to use for new subnet creation. Must be valid and available subranges of the VPC CIDR"
  validation {
    condition     = length(var.subnet_cidrs) == 2
    error_message = "Exactly 2 subnets must be provided."
  }
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "Availability zones to create the subnets in. If default, uses every availability zone in the region. If not default, must include at least two availability zones formatted as a list of strings, e.g. [\"us-east-1a\", \"us-east-1b\"]"
  validation {
    condition     = length(var.availability_zones) == 2 || length(var.availability_zones) == 0
    error_message = "If provided, must specify exactly 2 availability zones."
  }
}
