# Allow Project N to read Project N specific billing data

This module automates the provisioning of the resources that required to allow access [Google Cloud Billing data in BigQuery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery) to the Project N.

## Prerequisites

- [Terraform >= v0.15](https://www.terraform.io/downloads.html)
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)

## Usage

```shell script
git clone https://gitlab.com/projectn-oss/project-n-setup.git

cd project-n-setup/allow-billing-read/gcp

terraform init && terraform apply \
    -var="bolt_project_id=[bolt-project-id]" \
    -var="billing_project_id=[billing-project-id]" \
    -var="billing_dataset_id=[billing-dataset-id]" \
    -var="billing_projectn_view_id=[billing-projectn-view-id]" \
    -auto-approve
```

Before running the above command you've to replace the placeholders with actual values.

- bolt-project-id: This is project id where Project N's Bolt cluster running
- billing-dataset-id: This is BigQuery dataset id to which Google Cloud Detailed Billing export is configured.
- billing-project-id: This is project id of the BigQuery billing dataset.
- billing-projectn-view-id: This is view id of authorized BigQuery view created to allow access to only the bolt-project-id billing information

> Note: Assumption is that Google Cloud Billing export option 'Detailed usage cost' is already configured. If not please check the below `Links` section.

## Links

- [Set up Cloud Billing data export to BigQuery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-setup)
- [Understand the Cloud Billing data tables in BigQuery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-tables)
- [Set up Cloud Billing data export to BigQuery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-setup)
