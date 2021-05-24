variable "enable_write" {
  type        = bool
  default     = false
  description = "Grant write permissions"
}

variable "current_project" {
  type        = string
  description = "GCP project from which to grab the billing account and organization information"
}

variable "project" {
  type        = string
  default     = ""
  description = "GCP project where the admin server will be created"
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
