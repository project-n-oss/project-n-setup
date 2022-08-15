provider "google" {
  project = local.use_current_project_config ? null : var.current_project
  zone    = var.zone
}

provider "random" {
  # Configuration options
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.68"
    }
    random = {
      source = "hashicorp/random"
      version = "3.3.2"
    }
  }
}




