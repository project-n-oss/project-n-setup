locals {
  tags = var.default_tag == "" ? {} : {
    CustomID = var.default_tag
  }
}

// Provider for the original account. This is the default provider because it has no alias.
provider "aws" {
  profile = var.profile
  region  = var.region
  default_tags {
    tags = local.tags
  }
}

// Provider for the new account
provider "aws" {
  alias   = "new"
  profile = var.profile
  region  = var.region
  assume_role {
    role_arn = var.crunch_mode ? "arn:aws:iam::${module.account[0].account_id}:role/${local.organizational_iam_role_name}" : null
  }
  default_tags {
    tags = local.tags
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.42"
    }
  }
}