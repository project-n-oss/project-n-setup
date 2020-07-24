# Project N Admin Server

This module automates the provisioning of a Project N admin server in AWS. The following resources are created:
- `project-n-admin` IAM role and instance profile
- `project-n-admin-deploy`and `project-n-admin-vpc-permissions`IAM policies
- `project-n-admin-server`t2.micro instance in the default VPC for `region`. 
- `project-n-admin-ssh-access` security group

The Project N installer package from `package_url` is installed on launch, and the public DNS of the server is an output of the module.

## Usage
```shell script
terraform init
terraform apply
```
If not set, required values will be asked for interactively. Input variables can be configured using any of the methods described in the [Terraform documentation](https://www.terraform.io/docs/configuration/variables.html#assigning-values-to-root-module-variables)

This repository can also be used as a module alongisde other Terraform configuration.
```hcl
module "projectn" {
    source = "git::https://gitlab.com/projectnn/terraform-projectn-aws-admin-server.git"
    region = "us-east-2"
    key_name = "ec2-ssh-key"
    package_url = "https://s3.us-east-2.amazonaws.com/builds.projectn.co/2020-07-24-00-00-00/project-n-1.0.0_customer-1.x86_64.rpm"
} 
```

## Requirements

| Name | Version |
|------|---------|
| aws | ~> 2.70 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.70 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| key\_name | AWS EC2 key pair to use When connecting to the admin server over SSH | `string` | n/a | yes |
| manage\_vpc | Project N can automatically configure a VPC to launch into, but this requires elevated permissions. Set to false to disable these permissions if you would rather manually manage VPC resources | `bool` | `true` | no |
| package\_url | URL of the Project N package to install on launch | `string` | n/a | yes |
| region | AWS Region where the admin server will be created | `string` | n/a | yes |
| ssh\_access\_cidrs | Allow SSH access from the specified CIDR ranges. Defaults to 0.0.0.0/0, allowing access from anywhere. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_url | The URL to use to access the EC2 instance |
