variable "enable_write" {
  type        = bool
  default     = false
  description = "Grant write permissions"
}

variable "current_project" {
  type        = string
  default     = ""
  description = "Billing account and organization information obtained from this project if not specified otherwise"
}

variable "project" {
  type        = string
  default     = ""
  description = "Name of existing or new GCP project"
}

variable "create_project" {
  type      = bool
  default   = true
  description = "Create a new project? Otherwise use an existing project"
}

variable "zone" {
  type        = string
  description = "GCP compute/zone where the admin server will be created"
}

variable "billing_account" {
  type        = string
  default     = ""
  description = "GCP billing account ID"
}

variable "org_id" {
  type        = string
  default     = ""
  description = "GCP org ID"
}

variable "package_url" {
  type        = string
  description = "URL of the Project N package to install on launch"
}

variable "admin_server_instance_type" {
  type        = string
  description = "URL of the Project N package to install on launch"
  default = "n1-standard-1"
}
