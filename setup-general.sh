#!/bin/bash
set -eo pipefail

# -- Set up terraform ---------------------------------------------------------

current_version=0.15.4
echo $current_version > .terraform-version

install_tfenv() {
  git clone https://github.com/tfutils/tfenv.git ~/.tfenv
  echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.profile  # this is how the tfenv repo says to do it, but it's ugly
  . ~/.profile
}

# terraform version | sed -nE "s/^.*v(([[:digit:]]|\.)*)([^[:digit:]].*|$)/\1/p"  # current version number
# TODO ensure that this doesn't mess up an existing terraform installation
# check if the correct version of terraform is installed
if (! command -v terraform >/dev/null || ! terraform version 2>/dev/null | grep -q "v$current_version") && ! tfenv list 2>/dev/null | grep -q $current_version; then
  if ! command -v tfenv >/dev/null; then  # install tfenv if it doesn't already exist
    install_tfenv
  fi
  tfenv install $current_version  # could use latest or min-required
fi

# -- Get default values if no var file is provided ----------------------------

manual_var_file=./admin-server.tfvars

# This var file will be automatically used by Terraform.
var_file=./terraform.tfvars
# If the manual var file exists, don't automatically grab configuration information.
if [ -s $manual_var_file ]; then
  cp $manual_var_file $var_file
else
  # Note that this will overwrite an existing var file.
  cat "" > $var_file
  read -rp "Package URL to install: " package
  echo "package_url=\"$package\"" >> $var_file
  __PLATFORM_SPECIFIC_VARIABLE_SETUP__
fi



# -- Run terraform ------------------------------------------------------------

# The correct version should automatically be used because of the terraform-version file
terraform init
terraform apply

# -- SSH into the new admin server --------------------------------------------

__PLATFORM_SPECIFIC_PRE_SSH_SETUP__

# Retry until login is working
until eval "$login_command --command='echo'"
do
  echo "Waiting for login permissions to propagate..."
  sleep 10
done

until eval "$login_command --command='command -v projectn >/dev/null'"
do
  echo "Waiting for the Project N package to finish installing..."
  sleep 10
done

# Don't do this--it breaks the pretty formatting and makes it laggy
# eval "$login_command --command='projectn deploy'"

# login and stay logged in
eval "$login_command"
