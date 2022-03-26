locals {
  tags = var.default_tag == "" ? {} : {
    CustomID = var.default_tag
  }
}

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

data "aws_subnet" "admin_server_subnet" {
  count = var.subnet_id == null ? 0 : 1
  id    = var.subnet_id
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
  vpc_id      = coalescelist(data.aws_subnet.admin_server_subnet[*].vpc_id, tolist(data.aws_vpcs.default_vpc.ids))[0]

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
  key_name                    = local.ssh_key_name
  security_groups             = var.subnet_id == null ? [aws_security_group.ssh.name] : null
  vpc_security_group_ids      = var.subnet_id != null ? [aws_security_group.ssh.id] : null
  subnet_id                   = var.subnet_id
  volume_tags                 = local.tags
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = false
  }
  user_data = <<EOF
#!/bin/bash
yum -y update
yum -y install ${var.package_url}
su ec2-user -c 'pip3 install awscli awscli-plugin-bolt --user'
echo 'export PATH=~/.local/bin:$PATH' >> /home/ec2-user/.bash_profile && chown ec2-user /home/ec2-user/.bash_profile
su ec2-user -c 'source ~/.bash_profile && aws configure set region ${var.region} && aws configure set plugins.bolt awscli-plugin-bolt'
mkdir -p /home/ec2-user/.project-n/aws/default/infrastructure
echo '{"default_platform":"aws"}' > /home/ec2-user/.project-n/config
${local.vpc_conf}
chmod -R 755 /home/ec2-user/.project-n
chown -R ec2-user /home/ec2-user/.project-n
EOF

  tags = merge({ Name = "project-n-admin-server" }, var.default_tag != "" ? { CustomID = var.default_tag } : {})

  depends_on = [aws_key_pair.new]
}

locals {
  vpc_conf       = var.vpc_id == "" ? "" : "echo = \\\"${var.vpc_id}\\\" > /home/ec2-user/.project-n/aws/default/infrastructure/vpc.auto.tfvars"
  create_ssh_key = var.ssh_key_name == ""
  ssh_key_name   = local.create_ssh_key ? aws_key_pair.new[0].key_name : var.ssh_key_name
}

resource "tls_private_key" "new" {
  count     = local.create_ssh_key ? 1 : 0
  algorithm = "RSA"
}

resource "aws_key_pair" "new" {
  count           = local.create_ssh_key ? 1 : 0
  key_name_prefix = "project-n-${random_id.random_suffix.hex}"
  public_key      = tls_private_key.new[0].public_key_openssh
}
