// Crunch mode only (not estimate savings)

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

// todo: add permissions required to do this
resource "aws_organizations_account" "account" {
  name      = var.account_name
  email     = var.account_email
  role_name = var.organizational_iam_role_name
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs         = var.availability_zones == [] ? toset(data.aws_availability_zones.available.names) : var.availability_zones
  az_cidr_map = zipmap(slice(local.azs, 0, length(var.subnet_cidrs)), var.subnet_cidrs)
}

resource "aws_subnet" "subnets" {
  vpc_id            = var.vpc_id
  for_each          = local.az_cidr_map
  availability_zone = each.key
  cidr_block        = each.value // TODO do we have any reason to let people override this?
  tags = {
    "kubernetes.io/role/elb"          = 1
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "association" {
  route_table_id = aws_route_table.route_table.id
  for_each       = aws_subnet.subnets
  subnet_id      = aws_subnet.subnets[each.key].id
}

data "aws_internet_gateway" "gateway" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}
resource "aws_ram_resource_share" "share_subnets" {
  name = "project_n_shared_subnets"
}

resource "aws_ram_principal_association" "new_account_association" {
  principal          = aws_organizations_account.account.id
  resource_share_arn = aws_ram_resource_share.share_subnets.arn
}

resource "aws_ram_resource_association" "resource_association" {
  resource_share_arn = aws_ram_resource_share.share_subnets.arn
  for_each           = aws_subnet.subnets
  resource_arn       = aws_subnet.subnets[each.key].arn
}
