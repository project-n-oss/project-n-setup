# Project N Admin Server

This module automates the provisioning of a Project N admin server in AWS. The following resources are created:
- `project-n-admin` IAM role and instance profile
- `project-n-admin-deploy`and `project-n-admin-vpc-permissions`IAM policies
- `project-n-admin-server`t2.micro instance in the default VPC for `region`. 
- `project-n-admin-ssh-access` security group

The Project N installer package from `package_url` is installed on launch, and the public DNS of the server is an output of the module.

## Prereqs

Must have [Terraform v0.12](https://www.terraform.io/downloads.html) installed to use this module.

## Usage
```shell script
git clone https://gitlab.com/projectn-oss/terraform-projectn-aws-admin-server.git
cd terraform-projectn-aws-admin-server
terraform init
terraform apply
```
If not set, required values will be asked for interactively. Input variables can be configured using any of the methods described in the [Terraform documentation](https://www.terraform.io/docs/configuration/variables.html#assigning-values-to-root-module-variables)

This repository can also be used as a module alongisde other Terraform configuration.
### Examples
#### Command line inputs
Input variables can be passed as command line flags
```shell script
terraform apply -var region=<aws-region> -var key_name=<aws-key-name> -var package_url=<project-n-package-url>
```

#### Using `terraform.tfvars` file
Create a `terraform.tfvars` file within the `terraform-projectn-aws-admin-server` directory. Terraform will automatically load these variables when run with `terraform apply`
```hcl
region = "<aws-region>"
key_name = "<aws-key-name>"
package_url = "<project-n-package-url>"
ssh_access_cidrs = ["x.x.x.x/32"]
```

#### Module usage
This directory can also be used as a module in other Terraform configurations. To use as a module, create a file `projectn.tf`like the example below in a separate directory.
```hcl
module "projectn" {
    source = "git::https://gitlab.com/projectn-oss/terraform-projectn-aws-admin-server.git"
    region = "<aws-region>"
    key_name = "<aws-key-name>"
    package_url = "<project-n-package-url>"
} 
```
From the module directory, run 
```shell script
terraform init
terraform apply
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
| manage\_vpc | Project N can automatically configure a VPC to launch into. Set to false to disable these permissions if you would rather manually manage VPC resources | `bool` | `true` | no |
| package\_url | URL of the Project N package to install on launch | `string` | n/a | yes |
| region | AWS Region where the admin server will be created | `string` | n/a | yes |
| ssh\_access\_cidrs | Allow SSH access from the specified CIDR ranges. Defaults to 0.0.0.0/0, allowing access from anywhere. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_url | The URL to use to access the EC2 instance |
