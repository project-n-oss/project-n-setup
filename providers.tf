// provider for the original account
provider "aws" {
  alias   = "aws" // this is the default provider
  profile = var.profile
  region  = var.region
}

// todo: either ensure that the above is the assumed default provider, or explicitly add the provider to all resources

// provider for the new account
provider "aws" {
  alias = "new"
  // profile = "default"
  region = var.region
  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.account.arn}:role/ROLE_NAME"  // todo: is this var.organizational_iam_role_name ?
    // session_name = "SESSION_NAME"
    // external_id  = "EXTERNAL_ID"
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
