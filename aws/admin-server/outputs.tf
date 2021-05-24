output "instance_url" {
  value       = aws_instance.admin.public_dns
  description = "The URL to use to access the EC2 instance"
}

output "ssh_key" {
  value     = tls_private_key.new.private_key_pem
  sensitive = true
}