variable "org_id" {
  type        = string
  default     = ""
  description = "GCP org ID"
}

variable "bolt_project_id" {
  type        = string
  description = "GCP bolt cluster project ID"
}

variable "billing_project_id" {
  type        = string
  description = "GCP billing export project ID"
}

variable "billing_dataset_id" {
  type        = string
  description = "GCP billing export dataset ID"
}
