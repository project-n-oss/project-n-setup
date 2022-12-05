# --- Get required info using "data" first
# The route-table attached to the private subnets of requester (Project N) VPC
data aws_route_table "private_rt" {
  vpc_id = var.requester_vpc_id
  tags = {
    Name = "*private*"
  }
}

# The network_interface for quicksilver ELB
# So, we can attach new SG to these
data "aws_network_interfaces" "quicksilver_ni" {
  filter {
    name = "description"
    values = ["ELB app/k8s-default-quicksil-1bd9e57786/dbe2e195ea69eb8d"]
  }
  /*
  tags = {
    //Description = "*quick*"
    Description = "ELB app/k8s-default-quicksil-1bd9e57786/dbe2e195ea69eb8d"
  }
  */
}

output "out_private_rt" {
    value = data.aws_route_table.private_rt.id
}

output "out_network_interfaces" {
    value = data.aws_network_interfaces.quicksilver_ni.ids
}

# --- Create AWS resources
module "vpc-peer" {
  source = "./vpc-peer"
  for_each = var.peer_vpcs

  requester_vpc_id = var.requester_vpc_id
  requester_route_table_id = data.aws_route_table.private_rt.id
  accepter_vpc_id = each.value.vpc_id
  accepter_owner_id = each.value.owner_id
  accepter_cidr = each.value.cidr
}
