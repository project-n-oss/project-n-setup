output "ssh_command" {
  value       = "gcloud compute ssh ${local.ssh_username}@project-n-admin-server-${module.admin-server.admin_name_suffix} --project=${local.project} --zone=${local.zone}"
  description = "The command to ssh into the admin server"
}

output "scp_command" {
  value       = "gcloud compute scp --project=${local.project} --zone=${local.zone} %s ${local.ssh_username}@project-n-admin-server-${module.admin-server.admin_name_suffix}:~"
  description = "The command to copy files into the admin server"
}

output "admin_id" {
  value = module.admin-server.admin_id
}
