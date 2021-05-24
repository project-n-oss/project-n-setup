#!/bin/bash
set -eo pipefail

cd admin-server
terraform destroy

# TODO: uninstall terraform if it was previously installed?
