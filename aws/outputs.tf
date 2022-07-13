output "ssh_command" {
  value       = "ssh -i ssh_key.pem ec2-user@${local.instance_url}"
  description = "The command to ssh into the admin server"
}

output "scp_command" {
  value       = "scp -q -i ssh_key.pem %s ec2-user@${local.instance_url}:~"
  description = "The command to copy a file into the admin server"
}

output "ssh_key" {
  value       = local.ssh_key
  sensitive   = true
  description = "The admin server ssh key"
}

output "account_id" {
  value       = var.crunch_mode ? module.account[0].account_id : ""
  description = "The ID of the Project N AWS account"
}

output "vpc_id" {
  value = local.vpc.vpc_id
}

output "private_subnet_ids" {
  value = local.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = local.vpc.public_subnet_ids
}