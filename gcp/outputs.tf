output "ssh_command" {
  value       = "gcloud compute ssh ${local.ssh_username}@project-n-admin-server-${random_id.admin_name_suffix.hex} --project=${local.project} --zone=${local.zone}"
  description = "The command to ssh into the admin server"
}

output "scp_command" {
  value       = "gcloud compute scp --project=${local.project} --zone=${local.zone} %s ${local.ssh_username}@project-n-admin-server-${random_id.admin_name_suffix.hex}:~"
  description = "The command to copy files into the admin server"
}

output "admin_id" {
  value = google_compute_instance.admin.instance_id
}
