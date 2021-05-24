module "admin-server" {
  count            = var.crunch_mode ? 0 : 1
  source           = "./admin-server"
  key_name         = var.key_name
  manage_vpc       = var.manage_vpc
  package_url      = var.package_url
  ssh_access_cidrs = var.ssh_access_cidrs
  region           = var.region
  profile          = var.profile
  crunch_mode      = false
}

module "account" {
  count                        = var.crunch_mode ? 1 : 0
  source                       = "./account"
  account_email                = var.account_email
  account_name                 = var.account_name
  availability_zones           = var.availability_zones
  organizational_iam_role_name = var.organizational_iam_role_name
  subnet_cidrs                 = var.subnet_cidrs
  vpc_id                       = var.vpc_id
}

module "admin-server-new" {
  count = var.crunch_mode ? 1 : 0
  providers = {
    aws = aws.new
  }
  source           = "./admin-server"
  key_name         = var.key_name
  manage_vpc       = var.manage_vpc
  package_url      = var.package_url
  ssh_access_cidrs = var.ssh_access_cidrs
  region           = var.region
  profile          = var.profile
  crunch_mode      = true
}
