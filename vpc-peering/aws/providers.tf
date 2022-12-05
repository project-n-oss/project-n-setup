terraform {
  backend "s3" {
    # TBD: Obtains values from tfvars
    bucket = "n-tfst-dflta-2d4200"
    key    = "vpc-peering"
    region = "us-west-1"
    profile = "chetan-subaccount-role"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0" # TBD: version
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.1.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = "chetan-subaccount-role"
}
