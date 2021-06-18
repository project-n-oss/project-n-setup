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
}

locals {
  organizational_iam_role_name = "project-n-access"
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
  vpc_id                       = var.vpc_id
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
  vpc_id           = var.vpc_id

  depends_on = [module.account]
}
