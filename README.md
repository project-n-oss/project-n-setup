# Project N Admin Server

This module automates the provisioning of a Project N admin server in AWS. The following resources are created:
- `project-n-admin` IAM role and instance profile
- `project-n-admin-deploy`and `project-n-admin-vpc-permissions`IAM policies
- `project-n-admin-server`t2.micro instance in the default VPC for `region`. 
- `project-n-admin-ssh-access` security group

The Project N installer package from `package_url` is installed on launch, and the public DNS of the server is an output of the module.

## Prereqs

Must have [Terraform v0.12](https://www.terraform.io/downloads.html) installed to use this module.

AWS IAM Permission:

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.42 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.42 |
| <a name="provider_aws.new"></a> [aws.new](#provider\_aws.new) | ~> 3.42 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.admin-deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.admin-vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_organizations_account.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_ram_principal_association.new_account_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.resource_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.share_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route_table.route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.bolt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.dashboard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.workers_to_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [random_id.random_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_ami.amazon-linux-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpcs.default_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpcs) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_email"></a> [account\_email](#input\_account\_email) | Email for the AWS account that will be created. This must be an email you have access to. | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Name of the AWS account that will be created | `string` | `"Project N"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones to create the subnets in. If default, uses every availability zone in the region. If not default, must include at least two availability zones formatted as a list of strings, e.g. ["us-east-1a", "us-east-1b"] | `set(string)` | `[]` | no |
| <a name="input_crunch_mode"></a> [crunch\_mode](#input\_crunch\_mode) | Prepare to crunch data, rather than just estimating savings | `bool` | `false` | no |
| <a name="input_dashboard_cidr_range"></a> [dashboard\_cidr\_range](#input\_dashboard\_cidr\_range) | CIDR range where the dashboard can be accessed from | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | AWS EC2 key pair to use when connecting to the admin server over SSH | `string` | n/a | yes |
| <a name="input_manage_vpc"></a> [manage\_vpc](#input\_manage\_vpc) | Project N can automatically configure a VPC to launch into, but this requires elevated permissions. Set to false to disable these permissions if you would rather manually manage VPC resources | `bool` | `true` | no |
| <a name="input_organizational_iam_role_name"></a> [organizational\_iam\_role\_name](#input\_organizational\_iam\_role\_name) | Name of the organizational IAM role to start the account with | `string` | n/a | yes |
| <a name="input_package_url"></a> [package\_url](#input\_package\_url) | URL of the Project N package to install on launch | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | AWS profile to use for deployment | `string` | `"default"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region where the admin server will be created | `string` | n/a | yes |
| <a name="input_ssh_access_cidrs"></a> [ssh\_access\_cidrs](#input\_ssh\_access\_cidrs) | Allow SSH access from the specified CIDR ranges. Defaults to 0.0.0.0/0, allowing access from anywhere. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC of the applications you wish to connect to Bolt | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | The command to ssh into the admin server |