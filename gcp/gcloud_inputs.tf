data "google_client_config" "current" {
}

data "google_project" "current_project" {
  project_id = local.current_project
}

data "google_organization" "org" {
  organization = data.google_project.current_project.org_id
}

data "google_billing_account" "billing_account" {
  billing_account = data.google_project.current_project.billing_account
}

data "google_iam_role" "crunch_role" {
  name = local.crunch_role_path
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

locals {
  current_project = data.google_client_config.current.project
  create_project  = var.project == ""
  // Note: GCP Project IDs are limited to 30 chars
  project          = local.create_project ? join("-", ["project-n", random_id.random_suffix.hex]) : var.project
  zone             = var.zone == "" ? data.google_client_config.current.zone : var.zone
  org_id           = var.org_id == "" ? data.google_project.current_project.org_id : var.org_id
  billing_account  = var.billing_account == "" ? data.google_billing_account.billing_account.id : var.billing_account
  crunch_role_path = "organizations/${local.org_id}/roles/projectNCrunch"
}
