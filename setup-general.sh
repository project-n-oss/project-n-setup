#!/bin/bash
set -eo pipefail

# -- Set up command line arguments --------------------------------------------

manual_confirm=0
crunch_mode=0
no_deploy=0
convert=0
for arg in "$@"; do
  case "$arg" in
  --manual-confirm) manual_confirm=1 ;;
  --crunch) crunch_mode=1 ;;
  --no-deploy) no_deploy=1 ;;
  --convert) convert=1 ;;
  *)
    echo "Unrecognized argument: $arg"
    exit 1
    ;;
  esac
done

projectn_path="$HOME/.project-n-admin-server"
if ! [ -d $projectn_path ]; then
  mkdir "$projectn_path"
  git clone git@gitlab.com:projectn-oss/project-n-setup.git "$projectn_path"
else
  cd "$projectn_path"
  git pull
fi

__PLATFORM_SPECIFIC_CLI_SETUP__

# -- Set up terraform ---------------------------------------------------------

current_version=0.15.4
echo $current_version >.terraform-version

install_tfenv() {
  git clone https://github.com/tfutils/tfenv.git ~/.tfenv
  echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >>~/.profile
  . ~/.profile
}

# Check if the correct version of terraform is installed.
if (! command -v terraform >/dev/null || ! terraform version 2>/dev/null | grep -q "v$current_version") && ! tfenv list 2>/dev/null | grep -q $current_version; then
  # Install tfenv if it doesn't already exist.
  if ! command -v tfenv >/dev/null; then
    install_tfenv
  fi
  tfenv install $current_version
fi

# -- Get default values if the var file is not already configured -------------

# This var file will be automatically used by Terraform.
var_file=./terraform.tfvars
# If the manual var file exists, don't automatically grab configuration information.
new_deployment=0
if [ ! -s $var_file ]; then
  new_deployment=1
fi

add_crunch=0
if [[ ("$new_deployment" == "1" && "$crunch_mode" == "1") || "$convert" == "1" ]]; then
  add_crunch=1
fi

if [ "$convert" == "1" ]; then
  cp $var_file $var_file.old
fi

#content = {
#            'customer_id': flags.nenv['customer_id'],
#            'from_version': flags.nenv['release_version'],
#            'target': 'rpm'
#        }
#        if to_version is not None:
#            content['to_version'] = to_version
#
#        resp = post(f"{flags.nenv['serverless_endpoint']}/latest-version", json=content)

# TODO: this works, but the customer_id field needs to be set appropriately
# serverless_endpoint="https://uycmtoytcc.execute-api.us-east-1.amazonaws.com/prod"
# curl -X POST -H "Content-Type: application/json" --data '{"customer_id": "frame-io","from_version": "v0.0.0","target": "rpm"}' $serverless_endpoint/latest-version
# response is:
# {"package_url":"https://s3.us-east-2.amazonaws.com/builds.projectn.co/2021-05-13-15-12-16/project-n-frame-io-1.5.5.x86_64.rpm","version":"v1.5.5","update_infrastructure":true,"update_software":true,"data_cruncher_only":false,"yum_command":"downgrade","images":null}
# if out is response, then this extracts just the url:
# echo $out | grep -Eo '"package_url":.*?[^\\]",' | cut -d "\"" -f4
# after installation, unclear if a new customer id should be configured, since that will make updating not work properly
# to convert to connect apps, what changes need to be made?
# if it's just disabling crunch limits, only need `projectn config delete-flagset crunch-limits-100gb`

if [ "$new_deployment" -eq "1" ]; then
  cat >$var_file <<EOT
# Edit this file to customize the configuration.

# URL of the Project N package to install on the admin server.
# This package is custom-built for you and automatically included here.
# WARNING: changes here force the admin server to be destroyed and recreated.
# This may leave deployment resources stranded. After installation, the package
# is updated automatically; if a manual update is required, instead of changing
# this, run 'sudo yum -y reinstall <new-package>' in the admin server.
package_url          = "__PACKAGE_URL__"

EOT
fi

if [ "$add_crunch" -eq "1" ]; then
  read -rp "Custom domain to use: " custom_domain
fi

__PLATFORM_SPECIFIC_VARIABLE_SETUP__

# -- Run terraform ------------------------------------------------------------

# Leave tf_args unset if not manual_confirm.
if [ "$manual_confirm" -eq "0" ]; then
  tf_args="-auto-approve"
fi

# The terraform-version file specifies the version to use.
terraform init
terraform apply "$tf_args"

__PLATFORM_SPECIFIC_PRE_SSH_SETUP__

until eval "$test_command'echo' >/dev/null" 2>log; do
  handle_ssh_errors "$(cat log)"
  echo "Waiting for login permissions to propagate..."
  sleep 10
done

until eval "$test_command'command -v projectn >/dev/null'" 2>log; do
  handle_ssh_errors "$(cat log)"
  echo "Waiting for the Project N package to finish installing..."
  sleep 10
done

rm log

# Prepare to deploy
__PLATFORM_SPECIFIC_DEPLOY__

# Login and stay logged in
eval "$login_command"
