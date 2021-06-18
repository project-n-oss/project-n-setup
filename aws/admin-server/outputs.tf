output "instance_url" {
  value       = aws_instance.admin.public_dns
  description = "The URL to use to access the EC2 instance"
}

output "ssh_key" {
  value     = local.create_ssh_key ? tls_private_key.new[0].private_key_pem : ""
  sensitive = true
  description = "The admin server ssh key"
}