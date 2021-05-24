resource "google_project" "project_n" {
  count               = local.create_project ? 1 : 0
  name                = "Project N"
  project_id          = local.project
  auto_create_network = true
  billing_account     = local.billing_account
  org_id              = local.org_id
}

resource "google_project_service" "container" {
  project            = local.project
  service            = "container.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project.project_n]
}

resource "google_project_service" "compute" {
  project            = local.project
  service            = "compute.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project.project_n]
}

resource "google_project_service" "logging" {
  project            = local.project
  service            = "logging.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project.project_n]
}

resource "google_project_service" "monitoring" {
  project            = local.project
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project.project_n]
}

resource "google_project_service" "manager" {
  project            = local.project
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project.project_n]
}

resource "google_project_service" "pubsub" {
  project            = local.project
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
  depends_on         = [google_project.project_n]
}
