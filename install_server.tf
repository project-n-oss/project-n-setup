data "aws_vpcs" "default_vpc" {
  filter {
    name = "isDefault"
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
  name        = "project-n-admin-ssh-access"
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
  iam_instance_profile        = aws_iam_instance_profile.admin.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  security_groups             = [aws_security_group.ssh.name]
  user_data                   = "#!/bin/bash\nsudo yum -y install ${var.package_url}"

  tags = {
    Name = "project-n-admin-server"
  }
}