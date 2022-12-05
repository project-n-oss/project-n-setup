# Create VPC Peering connection
resource aws_vpc_peering_connection "p_connection" {
  vpc_id        = var.requester_vpc_id
  peer_owner_id = var.accepter_owner_id
  peer_vpc_id   = var.accepter_vpc_id

  tags = {
    Name = format("VPC Peering for Project N - %s - %s",
      var.requester_vpc_id, var.accepter_vpc_id)
  }
}

# The route-table is created in krypton/packages/application/aws/infrastructure/vpc/vpc.tf
# We add one more route to it
resource aws_route "route_for_peer" {
  route_table_id = var.requester_route_table_id
  destination_cidr_block = var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.p_connection.id
}

# We will create a new security group with one rule
# to be attached to the ELB
resource "aws_security_group" "sg_for_peer" {
  name        = format("allow-peer-%s", var.accepter_vpc_id)
  description = format("Allow Traffic from peer vpc %s", var.accepter_vpc_id)
  vpc_id      = var.requester_vpc_id

  ingress {
    description      = "HTTPS from Peer VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.accepter_cidr]
  }
}

# TBD: How to attach this SG to the quicksilver ELB
