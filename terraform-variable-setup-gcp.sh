if [ "$new_deployment" -eq "1" ]; then
  billing_account_raw="$(gcloud beta billing accounts list --filter=open=true --limit=1 --format='get(name)')"
  billing_account=${billing_account_raw#"billingAccounts/"}
  read -rp "Use this billing account? $billing_account (Y/N) " billing_confirm
  if ! [[ "$billing_confirm" == "Y" || "$billing_confirm" == "y" ]]; then
    read -rp "Enter desired billing account ID: " billing_account
  fi

  org_id_raw="$(gcloud organizations list --limit=1 --format='get(name)')"
  org_id=${org_id_raw#"organizations/"}
  read -rp "Create the resources in this organization? $org_id (Y/N) " org_confirm
  if ! [[ "$org_confirm" == "Y" || "$org_confirm" == "y" ]]; then
    read -rp "Enter desired organization ID: " org_id
  fi

  compute_zone="$(gcloud config get-value compute/zone)"
  read -rp "Create the admin server in this compute/zone? $compute_zone (Y/N) " zone_confirm
  if ! [[ "$zone_confirm" == "Y" || "$zone_confirm" == "y" ]]; then
    read -rp "Enter desired compute/zone: " compute_zone
  fi

  cat >> $var_file <<EOT
# GCP billing account ID to use.
billing_account      = "$billing_account"

# Organization to create the resources in.
org_id               = "$org_id"

# GCP compute/zone to create the admin server in.
zone                 = "$compute_zone"

# Name of the new project to create.
# If not set, a project named project-n-<random-string> will be created.
EOT
  read -rp "Use a default project name of the form project-n-<random-string>? (Y/N) " key_confirm
  if ! [[ "$key_confirm" == "Y" || "$key_confirm" == "y" ]]; then
    read -rp "Enter the desired project name: " project_name
    echo "project              = \"$project_name\"" >> $var_file
  else
    echo "# project              = \"<project name>\"" >> $var_file
  fi
fi

if [ "$add_crunch" -eq "1" ]; then
  cat >> $var_file <<EOT

# Whether to grant Project N Bolt the permissions to edit buckets.
enable_write        = true
EOT
fi