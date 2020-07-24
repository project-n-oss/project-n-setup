output "instance_url" {
  value = aws_instance.admin.public_dns
  description = "The URL to use to access the EC2 instance"
}