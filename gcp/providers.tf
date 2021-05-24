provider "google" {
  project = var.current_project
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