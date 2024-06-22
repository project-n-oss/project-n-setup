output "ssh_command" {
  value       = module.admin-server.ssh_command
  description = "The command to ssh into the admin server"
}

output "scp_command" {
  value       = module.admin-server.scp_command
  description = "The command to copy files into the admin server"
}

output "admin_id" {
  value = module.admin-server.admin_id
}
