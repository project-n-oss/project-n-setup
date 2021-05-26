provider "google" {
  project = local.use_current_project_config ? null : var.current_project
  zone    = var.zone
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.68"
    }
  }
}