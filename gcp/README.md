# Project N Admin Server

This module automates the provisioning of the resources required to deploy Project N in GCP.
The Project N installer package from `package_url` is installed on launch, and the public DNS of the server is an output of the module.

## Prereqs

Must have [Terraform v0.15](https://www.terraform.io/downloads.html) and [the gcloud CLI](https://cloud.google.com/sdk/docs/install) installed to use this module.

## Usage
```shell script
git clone https://gitlab.com/projectn-oss/project-n-setup.git
cd project-n-setup/gcp
terraform init
terraform apply
```
If not set, required values will be asked for interactively. Input variables can be configured using any of the methods described in the [Terraform documentation](https://www.terraform.io/docs/configuration/variables.html#assigning-values-to-root-module-variables)

This repository can also be used as a module alongside other Terraform configuration.
### Examples
#### Command line inputs
Input variables can be passed as command line flags
```shell script
terraform apply -var zone=<gcp-compute/zone> -var package_url=<project-n-package-url>
```

#### Using `terraform.tfvars` file
Create a `terraform.tfvars` file within the `project-n-setup/gcp` directory. Terraform will automatically load these variables when run with `terraform apply`
```hcl
# URL of the Project N package to install on the admin server.
package_url          = "<project-n-package-url>"

# GCP billing account ID to use.
billing_account      = "<billing-id>"

# Organization to create the resources in.
org_id               = "<gcp-organization-id>"

# GCP compute/zone to create the admin server in.
zone                 = "<gcp-compute/zone>"

# Name of the new project to create.
# If not set, a project named project-n-<random-string> will be created.
# project              = "<project name>"

# Whether to grant Project N Bolt the permissions to edit buckets.
enable_write        = true
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.68 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.68 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_organization_iam_custom_role.project-n-role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_member.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project.project_n](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |
| [google_project_iam_member.project_permissions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.compute](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.container](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.logging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.monitoring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [random_id.random_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_billing_account.billing_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/billing_account) | data source |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_default_service_account.sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_default_service_account) | data source |
| [google_iam_role.crunch_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_role) | data source |
| [google_organization.org](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization) | data source |
| [google_project.current_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | GCP billing account ID | `string` | `""` | no |
| <a name="input_current_project"></a> [current\_project](#input\_current\_project) | GCP project from which to grab the billing account and organization information | `string` | `""` | no |
| <a name="input_enable_write"></a> [enable\_write](#input\_enable\_write) | Grant write permissions | `bool` | `false` | no |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | GCP org ID | `string` | `""` | no |
| <a name="input_package_url"></a> [package\_url](#input\_package\_url) | URL of the Project N package to install on launch | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | GCP project where the admin server will be created | `string` | `""` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP compute/zone where the admin server will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_id"></a> [admin\_id](#output\_admin\_id) | n/a |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | The command to ssh into the admin server |
