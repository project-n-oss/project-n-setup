provider "google" {
  project = local.use_current_project_config ? null : var.current_project
  zone    = var.zone
  // Null if not provided, defaults back to user account provided.
  credentials = "/root/.config/gcloud/application_default_credentials.json" # var.credentials
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.68"
    }
  }
}