
variable "bolt_project_id" {
  type        = string
  description = "GCP bolt cluster project ID"
}

variable "billing_project_id" {
  type        = string
  description = "GCP `Billing export` - Project name of `Detailed usage cost` section"
}

variable "billing_dataset_id" {
  type        = string
  description = "GCP `Billing export` - Dataset name of `Detailed usage cost` section"
}

variable "billing_projectn_view_id" {
  type        = string
  description = "GCP BigQuery billing dataset Project N billing authorized view ID"
}
