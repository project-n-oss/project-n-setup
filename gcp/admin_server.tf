resource "google_compute_instance" "admin" {
  name                    = "project-n-admin-server"
  project                 = local.project
  zone                    = local.zone
  machine_type            = "n1-standard-1"
  metadata_startup_script = <<EOF
#!/bin/bash
mkdir -p /home/${local.ssh_username}/.project-n
log="/home/${local.ssh_username}/.setup-log"
echo "=== Setup log ===" > $log
useradd ${local.ssh_username} 2>> $log
chown -R ${local.ssh_username} /home/${local.ssh_username} 2>> $log
echo $(ls -la /home/${local.ssh_username}) >> $log
echo $(ls -la /home/${local.ssh_username}/.project-n) >> $log
echo '{"default_platform":"gcp"}' > /home/${local.ssh_username}/.project-n/config 2>> $log
sudo yum -y install ${var.package_url} 2>> $log
sudo yum -y update
  EOF
  # labels, metadata, resource_policies, and tags are all set automatically, and may cause the server to be recreated.
  labels            = {}
  metadata          = {}
  resource_policies = []
  tags              = []
  depends_on        = [google_project_service.compute]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-8"
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
