// provider for the original account
provider "aws" {
  profile = var.profile
  region  = var.region
}

// todo: either ensure that the above is the assumed default provider, or explicitly add the provider to all resources

// provider for the new account
provider "aws" {
  alias   = "new"
  profile = var.profile
  region  = var.region
  assume_role {
    role_arn = var.crunch_mode ? "arn:aws:iam::${module.account[0].account_id}:role/${var.organizational_iam_role_name}" : null
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
