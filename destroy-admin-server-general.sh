#!/bin/bash
set -eo pipefail

auto_approve=0
for arg in "$@"
do
    if [ $arg = "--auto-approve" ]; then
      auto_approve=1
    else
      echo "Unrecognized argument: $arg"
    exit 1
    fi
done

# Leave tf_args unset if not manual_confirm
if [ "$auto_approve" -eq "1" ]; then
  tf_args="-auto-approve"
else
  read -rp "Are you sure you want to tear down your deployment? (Y/N) " teardown_confirm
  if ! [[ "$teardown_confirm" == "Y" || "$teardown_confirm" == "y" ]]; then
    exit 1
  fi
fi

projectn_path="$HOME/.project-n-admin-server"
__PLATFORM_SPECIFIC_DESTROY__
if eval "$test_command'echo' >/dev/null" 2> log; then
  echo "projectn teardown --auto-approve; exit 0" | $redirect_command
else
  echo "Warning: could not SSH into the admin server. If you had a deployment in the admin server but have not successfully run \`projectn teardown\`, proceeding may leave resources stranded."
  read -rp "Continue destroying the admin server anyway? (Y/N) " destroy_confirm
  if ! [[ "$destroy_confirm" == "Y" || "$destroy_confirm" == "y" ]]; then
    exit 1
  fi
fi
# The terraform-version file specifies the version to use
terraform destroy "$tf_args"

# TODO: uninstall terraform if it was previously installed?
