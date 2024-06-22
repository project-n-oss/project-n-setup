data "google_client_config" "current" {
}

data "google_project" "current_project" {
  count      = local.use_current_project_config ? 1 : 0
  project_id = var.current_project
}

data "google_organization" "org" {
  count        = local.use_current_project_config ? 1 : 0
  organization = data.google_project.current_project[0].org_id
}

data "google_billing_account" "billing_account" {
  count           = local.use_current_project_config ? 1 : 0
  billing_account = data.google_project.current_project[0].billing_account
}

data "google_iam_role" "crunch_role" {
  name = local.crunch_role_path
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

locals {
  use_current_project_config = var.current_project != "" # Only used to get billing and org info
  // Note: GCP Project IDs are limited to 30 chars
  project          = var.project == "" ? join("-", ["project-n", random_id.random_suffix.hex]) : var.project
  zone             = var.zone == "" ? data.google_client_config.current.zone : var.zone
  org_id           = var.org_id == "" ? data.google_project.current_project[0].org_id : var.org_id
  billing_account  = var.billing_account == "" ? data.google_billing_account.billing_account[0].id : var.billing_account
  crunch_role_path = "organizations/${local.org_id}/roles/projectNCrunch"
  ssh_username     = "projectn"
}

module "admin-server" {
  source        = "./admin-server"
  project       = local.project
  zone          = local.zone
  instance_type = var.admin_server_instance_type
  package_url   = var.package_url
}
