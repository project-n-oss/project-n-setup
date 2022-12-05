variable "region" {
  type = string
  description = "The AWS region to use. Both VPCs should be in this region (eg: us-west-1)"
}

variable "requester_vpc_id" {
  type = string
  description = "The requestor VPC. This is where Project N cluster is installed"
}

variable "peer_vpcs" {
  type = map(object({
    vpc_id = string
    owner_id = string
    cidr = string
  }))
  description = <<EOF
Information on the acceptor VPCs. This is usually where the application which will use Project N is hosted.
vpc_id: Acceptor VPC ID
owner_id: The AWS Account ID of the acceptor VPC
cidr: The IPv4 CIDR block of the acceptor VPC
EOF
}
