
data "google_compute_default_service_account" "bolt-project-sa" {
  project = var.bolt_project_id
}

locals {
  bolt_project_iam_member = "serviceAccount:${data.google_compute_default_service_account.bolt-project-sa.email}"
}

resource "google_project_iam_custom_role" "project-n-billing-data-role" {
  role_id     = "projectNBillingData"
  project     = var.billing_project_id
  title       = "Project N Billing Data Access"
  description = "To provide read only access to Project N billing data (bigquery dataset's table view, and destination/temporary table)"
  stage       = "GA"
  permissions = [
    "bigquery.tables.get",
    "bigquery.tables.getData",
  ]
}

resource "google_bigquery_dataset_iam_member" "project-n-billing-reader" {
  dataset_id = var.billing_dataset_id
  role       = google_project_iam_custom_role.project-n-billing-data-role.id
  member     = local.bolt_project_iam_member
  project    = var.billing_project_id
}

resource "google_project_iam_custom_role" "project-n-billing-query-role" {
  role_id     = "projectNBillingQuery"
  project     = var.bolt_project_id
  title       = "Project N Billing Query Job and Readsessions Access"
  description = "To provide resources access to compute a query on bigquery dataset table view."
  permissions = [
    "bigquery.jobs.create",
    "bigquery.readsessions.create",
    "bigquery.readsessions.getData",
  ]
}
