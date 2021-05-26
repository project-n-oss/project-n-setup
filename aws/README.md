# Project N Admin Server

This module automates the provisioning of the resources required to deploy Project N in AWS.
The Project N installer package from `package_url` is installed on launch, and the public DNS of the server is an output of the module.

## Prereqs

Must have [Terraform v0.15](https://www.terraform.io/downloads.html) and [the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed to use this module.

## Usage
```shell script
git clone https://gitlab.com/projectn-oss/project-n-setup.git
cd project-n-setup/aws
terraform init
terraform apply
```
If not set, required values will be asked for interactively. Input variables can be configured using any of the methods described in the [Terraform documentation](https://www.terraform.io/docs/configuration/variables.html#assigning-values-to-root-module-variables)

This repository can also be used as a module alongside other Terraform configuration.
### Examples
#### Command line inputs
Input variables can be passed as command line flags
```shell script
terraform apply -var region=<aws-region> -var profile=<aws-profile> -var package_url=<project-n-package-url>
```

#### Using `terraform.tfvars` file
Create a `terraform.tfvars` file within the `project-n-setup/aws` directory. Terraform will automatically load these variables when run with `terraform apply`
```hcl
# URL of the Project N package to install on the admin server.
package_url          = "<project-n-package-url>"

# AWS profile to use.
profile              = "<aws-profile>"

# AWS region in which to create the admin server.
region               = "<aws-region>"

# Whether to automatically set up the VPC.
# If set to false, manual configuration will be required.
manage_vpc           = true

# CIDR range from which SSH access to the admin server is permitted.
# If not set, doesn't restrict access.
# ssh_access_cidrs     = ["0.0.0.0/0"]

# Name of an existing AWS key pair to use with the admin server.
# If not set, creates a new key pair.
# ssh_key_name         = "<my_key_pair_name>"

# Crunch mode only below

# If true, set up the configuration recommended for crunching data;
# if false, set up the configuration recommended for estimating savings.
crunch_mode          = true

# If you would like to use an existing account, set this to false and set
# account_email to the email of the AWS account to run Project N Bolt from.
create_account       = true

# Email to use for the AWS account that will be created.
account_email        = "<email>"

# ID of the VPC of the applications you wish to connect to Bolt.
vpc_id               = "<vpc-id>"

# CIDR Ranges to use for new subnet creation.
# Must be two valid and available subranges of the VPC CIDR.
subnet_cidrs         = ["<cidr-1>", "<cidr-2>"]

# Availability zones to create the subnets in.
# If not set, uses every availability zone in the region.
# availability_zones   = ["<region>a", "<region>b"]

# CIDR range where the dashboard can be accessed from.
# If not set, doesn't restrict dashboard access.
# dashboard_cidr_range = ["0.0.0.0/0"]
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.42 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account"></a> [account](#module\_account) | ./account |  |
| <a name="module_admin-server"></a> [admin-server](#module\_admin-server) | ./admin-server |  |
| <a name="module_admin-server-new"></a> [admin-server-new](#module\_admin-server-new) | ./admin-server |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_email"></a> [account\_email](#input\_account\_email) | Email for the AWS account that will be created. This must be an email you have access to. | `string` | `""` | no |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Name of the AWS account to deploy Project N Bolt from. If create\_account is true, a new account with this name will be created. | `string` | `"Project N"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones to create the subnets in. If default, uses every availability zone in the region. If not default, must include at least two availability zones formatted as a list of strings, e.g. ["us-east-1a", "us-east-1b"] | `list(string)` | `[]` | no |
| <a name="input_create_account"></a> [create\_account](#input\_create\_account) | Whether to create an account from which to deploy Project N Bolt. | `bool` | `true` | no |
| <a name="input_crunch_mode"></a> [crunch\_mode](#input\_crunch\_mode) | Prepare to crunch data, rather than just estimating savings | `bool` | `false` | no |
| <a name="input_manage_vpc"></a> [manage\_vpc](#input\_manage\_vpc) | Project N can automatically configure a VPC to launch into, but this requires elevated permissions. Set to false to disable these permissions if you would rather manually manage VPC resources | `bool` | `true` | no |
| <a name="input_package_url"></a> [package\_url](#input\_package\_url) | URL of the Project N package to install on launch | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | AWS profile to use for deployment | `string` | `"default"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region where the admin server will be created | `string` | n/a | yes |
| <a name="input_ssh_access_cidrs"></a> [ssh\_access\_cidrs](#input\_ssh\_access\_cidrs) | Allow SSH access from the specified CIDR ranges. Defaults to 0.0.0.0/0, allowing access from anywhere. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Name of the key pair to use with the admin server. If not set, a new key pair is created. | `string` | `""` | no |
| <a name="input_subnet_cidrs"></a> [subnet\_cidrs](#input\_subnet\_cidrs) | CIDR Ranges to use for new subnet creation. Must be valid and available subranges of the VPC CIDR | `list(string)` | <pre>[<br>  "",<br>  ""<br>]</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC of the applications you wish to connect to Bolt | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | The command to ssh into the admin server |
| <a name="output_ssh_key"></a> [ssh\_key](#output\_ssh\_key) | The admin server ssh key |
