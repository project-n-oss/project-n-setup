data "google_compute_default_service_account" "sa" {
  project    = local.project
  depends_on = [google_project_service.compute, google_project_service.manager]
}

locals {
  iam_member = "serviceAccount:${data.google_compute_default_service_account.sa.email}"
}

resource "google_organization_iam_custom_role" "project-n-role" {
  count       = data.google_iam_role.crunch_role.id == null ? 1 : 0 # null if the role was not found
  role_id     = "projectNCrunch"
  org_id      = var.org_id
  title       = "Project N Storage Access"
  stage       = "GA"
  description = "Provides read access to all storage resources for Project N deployments"
  permissions = concat([
    "resourcemanager.projects.get",
    "resourcemanager.projects.list",
    "resourcemanager.projects.getIamPolicy",
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.buckets.update",
    "storage.buckets.getIamPolicy",
    "storage.objects.list",
    "storage.objects.get",
    "monitoring.timeSeries.list",
    "cloudasset.assets.analyzeIamPolicy",
    "cloudasset.assets.searchAllIamPolicies",
    "cloudasset.assets.searchAllResources",
    "iam.roles.get",
    "serviceusage.services.use",
    ], var.enable_write ? [
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.setIamPolicy",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.update",
  ] : [])
}

resource "google_project_iam_member" "project_permissions" {
  for_each = toset([
    "roles/container.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/logging.configWriter",
    "roles/storage.admin",
    "roles/compute.admin",
    "roles/pubsub.admin"
  ])
  role       = each.value
  project    = local.project
  member     = local.iam_member
  depends_on = [google_project.project_n]
}

resource "google_organization_iam_member" "viewer" {
  member     = local.iam_member
  org_id     = local.org_id
  role       = local.crunch_role_path
  depends_on = [google_organization_iam_custom_role.project-n-role]
}

// Note: Here org level role is chosen because of the customer's billing project may not be available (or yet to setup) at the time of running the Project N setup script
// Or move this section to gcp-billing-collector.tf (Krypton repo) to create the role based on target cusotmer billing project when hq_enabled flag is enabled
// Apart from table read permissions, you need few other permissions to run a query job, check the 'projectNBillingQuery' role in  gcp-billing-collector.tf (Krypton repo)
// 'projectNBillingData' should be binded at bigquery billing dataset (instead of table view) to allow destination/temporary tables as well
resource "google_organization_iam_custom_role" "project-n-billing-data-role" {
  role_id     = "projectNBillingData"
  org_id      = var.org_id
  title       = "Project N Billing Data Access"
  description = "To provide read only access to Project N billing data (bigquery dataset's table view, and destination/temporary table)"
  stage       = "GA"
  permissions = [
    "bigquery.tables.get",
    "bigquery.tables.getData",
  ]
}

// TODO: MP - This can be project level role, and should be at stone-bounty-249217
resource "google_organization_iam_custom_role" "project-n-logs" {
  role_id     = "projectNLogs"
  org_id      = var.org_id
  title       = "Project N Logs Bucket Access"
  description = "Provides write access to project specific logs bucket"
  stage       = "GA"
  permissions = [
    "storage.objects.get",
    "storage.objects.create",
  ]
}
