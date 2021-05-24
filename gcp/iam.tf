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
    ], var.enable_write ? [
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.setIamPolicy",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.update",
  ] : [])
}

// the permissions below might not be adequate. if so, this block will have all required permissions:
//resource "google_project_iam_member" "project_permissions" {
//  role       = "roles/owner"
//  project    = local.project
//  member     = local.iam_member
//  depends_on = [google_project.project_n]
//}

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

# TODO: i think it needs the ability to list and set pubsub iam policies in the new project
# "pubsub.topics.getIamPolicy"

resource "google_organization_iam_member" "viewer" {
  member     = local.iam_member
  org_id     = local.org_id
  role       = local.crunch_role_path
  depends_on = [google_organization_iam_custom_role.project-n-role]
}


