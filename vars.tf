variable "crunch_mode" {
  type        = bool
  default     = false
  description = "Prepare to crunch data, rather than just estimating savings"  // todo activate this
}

variable "region" {
  type        = string
  description = "AWS Region where the admin server will be created"
}

variable "key_name" {
  type        = string
  description = "AWS EC2 key pair to use when connecting to the admin server over SSH"
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

// for estimate savings only, i think
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

// Crunch mode only (not estimate savings)

// todo: group these together instead of having "count = crunch_mode ? 1 : 0" at the top of every resource

variable "account_name" {
  type        = string
  default     = "Project N"
  description = "Name of the AWS account that will be created"
}

variable "account_email" {
  type        = string
  description = "Email for the AWS account that will be created. This must be an email you have access to."
}

variable "organizational_iam_role_name" {
  type        = string
  description = "Name of the organizational IAM role to start the account with" // TODO should this be the crunch role? or some default role?
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC of the applications you wish to connect to Bolt"
}

variable "availability_zones" {
  type        = set(string)
  default     = []
  description = "Availability zones to create the subnets in. If default, uses every availability zone in the region. If not default, must include at least two availability zones formatted as a list of strings, e.g. [\"us-east-1a\", \"us-east-1b\"]"
}

variable "dashboard_cidr_range" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR range where the dashboard can be accessed from"
}
