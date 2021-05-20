//output "instance_url" {
//  value = aws_instance.admin.public_dns
//  description = "The URL to use to access the EC2 instance"
//}

output "ssh_command" {
  value       = "ssh -i '<KEY_PAIR.pem>' ec2-user@${aws_instance.admin.public_dns}"
  description = "The command to ssh into the admin server"
}
