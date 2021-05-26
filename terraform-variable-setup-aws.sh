if [ "$new_deployment" -eq "1" ]; then
  profile="default"
  read -rp "Use this AWS CLI profile? $profile (Y/N) " profile_confirm
  if ! [[ "$profile_confirm" == "Y" || "$profile_confirm" == "y" ]]; then
    read -rp "Enter desired AWS CLI profile: " profile
  fi

  region="$(aws configure get region --profile "$profile" || echo failure)"
  if [[ "$region" == "failure" ]]; then
    read -rp "Enter desired region: " region
  fi

  cat >> $var_file <<EOT
# AWS profile to use.
profile              = "$profile"

# AWS region in which to create the admin server.
region               = "$region"

# Whether to automatically set up the VPC.
# If set to false, manual configuration will be required.
manage_vpc           = true

# CIDR range from which SSH access to the admin server is permitted.
# If not set, doesn't restrict access.
EOT

  ssh_access_cidrs=["0.0.0.0/0"]
  read -rp "Allow SSH access to the admin server from all CIDRs? (Y/N) " ssh_access_confirm
  if ! [[ "$ssh_access_confirm" == "Y" || "$ssh_access_confirm" == "y" ]]; then
    read -rp "Enter CIDR range to restrict SSH access to (in the format [\"a\", \"b\", ...]): " ssh_access_cidrs
    echo "ssh_access_cidrs     = \"$ssh_access_cidrs\"" >> $var_file
  else
    echo "# ssh_access_cidrs     = [\"0.0.0.0/0\"]" >> $var_file
  fi

  cat >> $var_file <<EOT
# Name of an existing AWS key pair to use with the admin server.
# If not set, creates a new key pair.
EOT

  read -rp "Generate a new key pair to use with the admin server (recommended)? (Y/N) " key_confirm
  if ! [[ "$key_confirm" == "Y" || "$key_confirm" == "y" ]]; then
    echo "Enter the name of an existing AWS key pair to use with the admin server."
    read -rp "You must put a copy of this key in a file named ssh_key.pem in the $projectn_path/aws directory.: " ssh_key_name
    echo "ssh_key_name         = \"$ssh_key_name\"" >> $var_file
  else
    echo "# ssh_key_name         = \"<key-pair-name\"" >> $var_file
  fi
fi

if [ "$add_crunch" -eq "1" ]; then
  account_name="Project N"
  read -rp "Would you like to create a new AWS account (recommended) (Y) or use a separate existing AWS account (N)? " new_account_raw
  if [[ "$new_account_raw" == "Y" || "$new_account_raw" == "y" ]]; then
    new_account=true
    read -rp "Use this account name? $account_name (Y/N) " account_name_confirm
      if ! [[ "$account_name_confirm" == "Y" || "$account_name_confirm" == "y" ]]; then
       read -rp "Enter desired AWS account name: " account_name
      fi
  else
    if [[ "$new_account_raw" == "N" || "$new_account_raw" == "n" ]]; then
      new_account=false
    else
      echo "Please respond with Y or N."
      exit 1
    fi
  fi
  read -rp "Email for the separate AWS account. If you are creating a new account, this must be an email you have access to: " email
  read -rp "ID of the VPC of the applications you wish to connect to Bolt: " vpc_id
  read -rp "CIDR Ranges to use for new subnet creation. Must be two valid and available subranges of the VPC CIDR in the format [\"a\", \"b\"]: " subnet_cidrs
  cat >> $var_file <<EOT

# If true, set up the configuration recommended for crunching data;
# if false, set up the configuration recommended for estimating savings.
crunch_mode          = true

# If you would like to use an existing account, set this to false and set
# account_email to the email of the AWS account to run Project N Bolt from.
create_account       = $new_account

# Email to use for the AWS account to run Project N Bolt from.
account_email        = "$email"

# Name of the AWS account to create if create_account is true. Ignored otherwise.
account_name         = "$account_name"

# ID of the VPC of the applications you wish to connect to Bolt.
vpc_id               = "$vpc_id"

# CIDR Ranges to use for new subnet creation.
# Must be two valid and available subranges of the VPC CIDR.
subnet_cidrs         = $subnet_cidrs

# Availability zones to create the subnets in.
# If not set, uses every availability zone in the region.
# availability_zones   = ["<region>a", "<region>b"]
EOT
fi

if [ "$convert" -eq "1" ]; then
  read -rp "Converting to a dual-account setup requires destroying the previous cluster. Proceed? (Y/N) " teardown_confirm
  if ! [[ "$teardown_confirm" == "Y" || "$teardown_confirm" == "y" ]]; then
    cp $var_file.old $var_file  # Undo the changes to the var file so that rerunning the script won't append changes twice
    exit 1
  fi
  old_test_command="$(terraform output -raw ssh_command) $args"
  old_redirect_command="ssh -tt $(echo $old_test_command | cut -c4-)"
  if eval "$old_test_command'echo' >/dev/null" 2> log; then
    echo "projectn teardown --auto-approve; exit 0" | $old_redirect_command
  else
    echo "Warning: could not SSH into the admin server. If you had a deployment in the admin server but have not successfully run \`projectn teardown\`, proceeding may leave resources stranded."
    read -rp "Continue destroying the admin server anyway? (Y/N) " destroy_confirm
    if ! [[ "$destroy_confirm" == "Y" || "$destroy_confirm" == "y" ]]; then
      cp $var_file.old $var_file  # Undo the changes to the var file so that rerunning the script won't append changes twice
      exit 1
    fi
  fi
fi
