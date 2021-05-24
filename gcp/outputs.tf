output "ssh_command" {
  value       = "gcloud compute ssh projectn@project-n-admin-server --project=${local.project} --zone=${local.zone}"
  description = "The command to ssh into the admin server"
}
