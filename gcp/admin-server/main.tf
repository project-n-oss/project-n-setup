resource "random_id" "admin_name_suffix" {
  keepers = {
    # Generate a new id if anything is changed which will create a new admin server
    project      = var.project
    zone         = var.zone
    machine_type = var.instance_type
  }
  byte_length = 3
}

resource "google_compute_instance" "admin" {
  name                    = "project-n-admin-server-${random_id.admin_name_suffix.hex}"
  project                 = var.project
  zone                    = var.zone
  description             = "Project N cluster management instance."
  machine_type            = var.instance_type
  metadata_startup_script = <<EOF
#!/bin/bash
set -e
mkdir -p /home/${var.ssh_username}/.project-n
log="/home/${var.ssh_username}/.setup-log"
echo "=== Setup log ===" > $log
useradd ${var.ssh_username} 2>> $log
chown -R ${var.ssh_username} /home/${var.ssh_username} 2>> $log
echo $(ls -la /home/${var.ssh_username}) >> $log
echo $(ls -la /home/${var.ssh_username}/.project-n) >> $log
echo '{"default_platform":"gcp"}' > /home/${var.ssh_username}/.project-n/config 2>> $log
sudo yum -y update
sudo yum -y install ${var.package_url} 2>> $log
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
sudo dnf install -y google-cloud-cli 2>> $log
sudo dnf install -y google-cloud-cli-gke-gcloud-auth-plugin 2>> $log
  EOF
  # labels, metadata, resource_policies, and tags are all set automatically, and may cause the server to be recreated.
  labels            = {}
  metadata          = {}
  resource_policies = []
  tags              = []

  boot_disk {
    initialize_params {
      image = var.boot_image
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
