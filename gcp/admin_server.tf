resource "google_compute_instance" "admin" {
  name                    = "project-n-admin-server"
  project                 = local.project
  zone                    = local.zone
  machine_type            = "n1-standard-1"
  metadata_startup_script = "sudo yum -y install ${var.package_url}"
  depends_on              = [google_project_service.compute]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-8"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
