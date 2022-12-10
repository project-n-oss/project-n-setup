
data "google_compute_default_service_account" "bolt-project-sa" {
  project = var.bolt_project_id
}

locals {
  bolt_project_iam_member = "serviceAccount:${data.google_compute_default_service_account.bolt-project-sa.email}"
}

resource "google_project_iam_custom_role" "project-n-billing-data-role" {
  project     = var.billing_project_id
  role_id     = "projectNBillingData"
  title       = "Project N Billing Data Access"
  description = "To provide read only access to the BigQuery authorized view that allows to query the Project N billing data"
  stage       = "GA"
  permissions = [
    "bigquery.tables.get",
    "bigquery.tables.getData",
  ]
}

resource "google_bigquery_table_iam_member" "project-n-billing-reader" {
  project    = var.billing_project_id
  dataset_id = var.billing_dataset_id
  table_id   = var.billing_projectn_view_id
  role       = google_project_iam_custom_role.project-n-billing-data-role.id
  member     = local.bolt_project_iam_member
}

resource "google_project_iam_custom_role" "project-n-billing-query-role" {
  project     = var.bolt_project_id
  role_id     = "projectNBillingQuery"
  title       = "Project N Billing Query Job and Readsessions Access"
  description = "To provide access to compute resources that require to execute a query in BigQuery"
  permissions = [
    "bigquery.jobs.create",
    "bigquery.readsessions.create",
    "bigquery.readsessions.getData",
  ]
}

resource "google_project_iam_member" "project-n-billing-query-executor" {
  project = var.bolt_project_id
  role    = google_project_iam_custom_role.project-n-billing-query-role.id
  member  = local.bolt_project_iam_member
}
