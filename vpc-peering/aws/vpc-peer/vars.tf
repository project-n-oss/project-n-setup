variable "requester_vpc_id" {
  type = string
  description = "The requestor VPC. This is where Project N cluster is installed"
}

variable "requester_route_table_id" {
  type = string
  description = "The route table in requester VPC where new route should be added"
}

variable "accepter_vpc_id" {
  type = string
  description = "The acceptor VPC. This is usually where the application which will use Project N is hosted"
}

variable "accepter_owner_id" {
  type = string
  description = "The AWS Account ID of the acceptor VPC"
}

variable "accepter_cidr" {
  type = string
  description = "The IPv4 CIDR block of the acceptor VPC"
}
