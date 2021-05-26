  read -rp "AWS profile to use (can be \"default\"): " profile
  read -rp "Name of the key pair to create to use with the login server: " key_name
  cat >> $var_file <<EOT
crunch_mode                  = false  # only estimate savings for now
key_name                     = "$key_name"
profile                      = "$profile"
region                       = "$(aws configure get region)"
ssh_access_cidrs             = ["0.0.0.0/0"]

# these only matter in crunch mode
account_email                = ""
manage_vpc                   = false
organizational_iam_role_name = ""
subnet_cidrs                 = ["", ""]
vpc_id                       = ""
EOT
