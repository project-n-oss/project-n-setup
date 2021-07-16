locals {
  create_ssh_key = var.ssh_key_name == ""
  instance_url   = var.crunch_mode ? module.admin-server-new[0].instance_url : module.admin-server[0].instance_url
  ssh_key        = local.create_ssh_key ? (var.crunch_mode ? module.admin-server-new[0].ssh_key : module.admin-server[0].ssh_key) : ""
}

output "ssh_command" {
  value       = "ssh -i ssh_key.pem ec2-user@${local.instance_url}"
  description = "The command to ssh into the admin server"
}

output "ssh_key" {
  value     = local.ssh_key
  sensitive = true
  description = "The admin server ssh key"
}

output "account_id" {
  value = var.crunch_mode ? module.account[0].account_id : ""
  description = "The ID of the Project N AWS account"
}
