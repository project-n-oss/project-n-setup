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
  key_name                    = var.key_name
  security_groups             = [aws_security_group.ssh.name]
  user_data                   = "#!/bin/bash\nsudo yum -y install ${var.package_url}; aws configure set region ${var.region}"

  tags = {
    Name = "project-n-admin-server"
  }
}

// Crunch mode only (not estimate savings)

data aws_vpc "vpc" {
  id = var.vpc_id
}

// todo: add permissions required to do this
resource "aws_organizations_account" "account" {
  name  = var.account_name
  email = var.account_email
}

data "aws_availability_zones" "available" {
  provider = aws.new
  state    = "available"
}

resource "aws_subnet" "subnets" {
  provider          = aws.new
  vpc_id            = var.vpc_id
  for_each          = var.availability_zones == [] ? toset(data.aws_availability_zones.available.names) : var.availability_zones
  availability_zone = each.key
  cidr_block        = "10.0.1.0/24" // TODO do we have any reason to let people override this?
  tags              = {
    "kubernetes.io/role/elb"          = 1
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "association" {
  route_table_id = aws_route_table.route_table
  for_each = aws_subnet.subnets
  subnet_id = aws_subnet.subnets[each.key].id
}

// todo if it's already attached to a gateway, use that
resource "aws_internet_gateway" "gateway" {
  vpc_id = var.vpc_id
}

resource "aws_ram_resource_share" "share_subnets" {
  name = "project_n_shared_subnets"
}

resource "aws_ram_principal_association" "new_account_association" {
  principal = aws_organizations_account.account.arn
  resource_share_arn = aws_ram_resource_share.share_subnets.arn
}

resource "aws_ram_resource_association" "resource_association" {
  resource_share_arn = aws_ram_resource_share.share_subnets.arn
  for_each           = aws_subnet.subnets
  resource_arn       = aws_subnet.subnets[each.key].arn
}

resource "aws_security_group" "cluster" {
  provider           = aws.new
  // allow all
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

// HTTPS from workers security group. This is a separate resource to avoid a cycle between the workers and cluster security groups
resource "aws_security_group_rule" "workers_to_cluster" {
  provider                 = aws.new
  type                     = "ingress"
  source_security_group_id = aws_security_group.workers.id
  security_group_id        = aws_security_group.cluster.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group" "workers" {
  provider = aws.new

  // All TCP from bolt and dashboard security groups
  ingress {
    security_groups = [aws_security_group.bolt.id, aws_security_group.dashboard.id]
    from_port       = 0
    to_port         = 0 // todo
    protocol        = "tcp"
  }

  // Custom TCP range 1025-65535 from the cluster security group
  ingress {
    security_groups = [aws_security_group.cluster.id]
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
  }

  // HTTPS from the cluster security group
  ingress {
    security_groups = [aws_security_group.cluster.id]
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
  }

  // All traffic from the workers security group
  ingress {
    self      = true
    from_port = 0
    to_port   = 0
    protocol  = "-1" // all
  }

  // allow all
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "bolt" {
  provider = aws.new

  // HTTP from the CIDR range of the shared VPC
  ingress {
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }

  // HTTPS from the CIDR range of the shared VPC
  ingress {
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }

  // allow all
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "dashboard" {
  provider = aws.new

  // HTTP from 0.0.0.0/0, or a custom CIDR range if you'd like to restrict where the dashboard can be accessed from
  ingress {
    cidr_blocks = var.dashboard_cidr_range
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }

  // HTTPS from 0.0.0.0/0, or a custom CIDR range if you'd like to restrict where the dashboard can be accessed from
  ingress {
    cidr_blocks = var.dashboard_cidr_range
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
}
