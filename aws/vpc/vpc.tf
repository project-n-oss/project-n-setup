module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "= 2.70.0"

  name                 = "${local.prefix}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = local.azs
  enable_dns_hostnames = true
  // Create a public and private subnet for each AZ
  public_subnets      = cidrsubnets(local.public_cidr, [for _ in local.azs : 3]...) # use /20 subnets (4K IP addresses) - there shouldn't be more than 8 AZs in a region
  private_subnets     = cidrsubnets(local.private_cidr, [for _ in local.azs : 3]...)
  public_subnet_tags  = merge(local.cluster_tag, local.public_tags)
  private_subnet_tags = merge(local.cluster_tag, local.private_tags)
  # public_subnet_tags  = local.public_tags
  # private_subnet_tags = local.private_tags
  # We have a couple different options for how provision NAT gateways, currently provisioning a single NAT gateway for all AZs
  # see more at https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#nat-gateway-scenarios
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_s3_endpoint = true
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

locals {
  public_cidr  = cidrsubnet(var.vpc_cidr, 1, 0)
  private_cidr = cidrsubnet(var.vpc_cidr, 1, 1)
  az_id_to_name    = zipmap(data.aws_availability_zones.available.zone_ids, data.aws_availability_zones.available.names)
  all_az_names       = [for _, az_name in local.az_id_to_name : az_name]
  azs    = slice(local.all_az_names, 0, 2)
  cluster_tag  = { "kubernetes.io/cluster/adminserver" = "shared" }
  public_tags  = { "kubernetes.io/role/elb" = "1", "Tier" = "Public" }
  private_tags = { "kubernetes.io/role/internal-elb" = "1", "Tier" = "Private" }
  vpc_cidr     = var.vpc_cidr
}
