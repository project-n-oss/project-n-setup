# Allow Project N to read Project N specific billing data

This module automates the provisioning of the resources that required to allow access [Google Cloud Billing data in BigQuery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery) to the Project N.

## Prerequisites

- [Terraform >= v0.15](https://www.terraform.io/downloads.html)
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)

## Usage

```shell script
git clone https://gitlab.com/projectn-oss/project-n-setup.git

cd project-n-setup/patch/gcp

chmod +x allow_billing_read.sh

./allow_billing_read.sh \
--bolt-project [bolt-project-id] \
--billing-dataset [billing-dataset-id] \
--billing-project [billing-project-id]
```

- bolt-project-id : This is project id where Project N's Bolt cluster running
- billing-dataset: This is the BigQuery dataset id to which Google Cloud detailed billing export is configured.
- billing-project-id: This is billing project id of the billing dataset.

FYI: Billing dataset table view is required to collect Project N specific billing data periodically, but not here. The `allow_billing_read.sh` script requires only the above mentioned three values.

**Note: Assumption is that 'Detailed usage cost' billing export option is already enabled. If not please check the below `Links` section.**

## Links

- [Set up Cloud Billing data export to BigQuery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-setup)
- [Understand the Cloud Billing data tables in BigQuery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-tables)
- [Set up Cloud Billing data export to BigQuery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-setup)
