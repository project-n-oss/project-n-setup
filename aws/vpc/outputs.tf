output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "igw_id" {
  description = "ID of the database internet gateway route"
  value       = module.vpc.igw_id
}

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = module.vpc.azs
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}