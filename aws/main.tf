module "vpc" {
  count    = 1
  source   = "./vpc"
  vpc_cidr = var.vpc_cidr
}

# Subnets : public
resource "aws_subnet" "public" {
  vpc_id                  = module.vpc[0].vpc_id
  cidr_block              = local.admin_server_cidr
  availability_zone       = module.vpc[0].azs[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Admin_server_Subnet"
  }
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = module.vpc[0].vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc[0].igw_id
  }
  tags = {
    Name = "publicRouteTable"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}


module "admin-server" {
  count            = var.crunch_mode ? 0 : 1
  source           = "./admin-server"
  manage_vpc       = var.manage_vpc
  package_url      = var.package_url
  ssh_access_cidrs = var.ssh_access_cidrs
  region           = var.region
  profile          = var.profile
  ssh_key_name     = var.ssh_key_name
  crunch_mode      = false
  default_tag      = var.default_tag
  vpc_id           = module.vpc[0].vpc_id
  subnet_id        = aws_subnet.public.id
}

locals {
  organizational_iam_role_name = "project-n-access"
  vpc                          = module.vpc[0]
  admin_server_cidr            = cidrsubnet(module.vpc[0].vpc_cidr_block, 2, 1)
  create_ssh_key               = var.ssh_key_name == ""
  instance_url                 = var.crunch_mode ? module.admin-server-new[0].instance_url : module.admin-server[0].instance_url
  ssh_key                      = local.create_ssh_key ? (var.crunch_mode ? module.admin-server-new[0].ssh_key : module.admin-server[0].ssh_key) : ""
}

module "account" {
  count                        = var.crunch_mode ? 1 : 0
  source                       = "./account"
  account_email                = var.account_email
  account_name                 = var.account_name
  availability_zones           = var.availability_zones
  create_account               = var.create_account
  profile                      = var.profile
  organizational_iam_role_name = local.organizational_iam_role_name
  subnet_cidrs                 = var.subnet_cidrs
  vpc_id                       = module.vpc[0].vpc_id
  default_tag                  = var.default_tag
}

module "admin-server-new" {
  count = var.crunch_mode ? 1 : 0
  providers = {
    aws = aws.new
  }
  source           = "./admin-server"
  manage_vpc       = var.manage_vpc
  package_url      = var.package_url
  ssh_access_cidrs = var.ssh_access_cidrs
  region           = var.region
  profile          = var.profile
  ssh_key_name     = var.ssh_key_name
  crunch_mode      = true
  vpc_id           = module.vpc[0].vpc_id
  default_tag      = var.default_tag

  depends_on = [module.account]
}
