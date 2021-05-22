locals {
  instance_url = var.crunch_mode ? module.admin-server-new[0].instance_url : module.admin-server[0].instance_url
  pem_key      = var.crunch_mode ? module.admin-server-new[0].ssh_key : module.admin-server[0].ssh_key
}

output "ssh_command" {
  value       = "terraform output -raw pem_key > key.pem; chmod 400 key.pem; ssh -i key.pem ec2-user@${local.instance_url}"
  description = "The command to ssh into the admin server"
}

output "pem_key" {
  value     = local.pem_key
  sensitive = true
}