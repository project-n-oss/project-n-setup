terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.42"
    }
  }
}
data "aws_vpcs" "default_vpc" {
  filter {
    name   = "isDefault"
    values = [true]
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "project-n-admin-ssh-access-${random_id.random_suffix.hex}"
  description = "Allow SSH connections"
  vpc_id      = tolist(data.aws_vpcs.default_vpc.ids)[0]

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_access_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "admin" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.admin.name
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.new.key_name
  security_groups             = [aws_security_group.ssh.name]
  user_data                   = "#!/bin/bash\nsudo yum -y install ${var.package_url}; su ec2-user && aws configure set region ${var.region}"

  tags = {
    Name = "project-n-admin-server"
  }
}

// When running in crunch mode, we'll need to bootstrap a new key for the admin server, since one won't exist yet
// There may be a better way of doing this.
resource "tls_private_key" "new" {
  algorithm = "RSA"
}
resource "aws_key_pair" "new" {
  key_name_prefix = var.key_name
  public_key      = tls_private_key.new.public_key_openssh
}