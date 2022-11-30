#!/bin/bash
#
# Allows the Bolt cluster to access the Project N billing data (bigquery billing dataset table view)

RED="\033[31m"
BLUE="\033[34m"
YELLOW="\033[33m"
GREEN="\033[32m"
ENDCOLOR="\033[0m"

echo $(command -v terraform)

#######################################
# Get google cloud organization id
# Arguments:
#   None
# Outputs:
#   Writes organization id to stdout
#######################################
function get_org_id() {
  local org_id_raw
  org_id_raw="$(gcloud organizations list --limit=1 --format='get(name)')"
  local org_id=""
  if [[ -z "${org_id_raw}" ]]; then
    local current_project_id
    current_project_id="$(gcloud config list --format 'value(core.project)')"
    org_id="$(gcloud projects get-ancestors "${current_project_id}" --format=yaml | grep organization -B 1 | grep id: | cut -d "'" -f2)"
  else
    org_id=${org_id_raw#"organizations/"}
  fi

  echo "${org_id}" # This is one of hacks to return a string in a function
}

#######################################
# Get google cloud service account's email
# Arguments:
#   Google project id
# Outputs:
#   Writes service account email to stdout
#######################################
function get_service_account_email() {
  local sa_email
  sa_email=$(gcloud iam service-accounts list --project=$1 --filter="displayName:Compute Engine default service account" --format="value(email)")

  echo "${sa_email}" # This is one of hacks to return a string in a function
}

#######################################
# Prints colored error message
# Arguments:
#   Error message
# Outputs:
#   Writes to stdout
#######################################
error() {
  echo -e "${RED}\nError: $1 ${ENDCOLOR}"
}

#######################################
# Check whether pre-requisites (gcloud, terraform) installed or not
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stdout and exit in case of pre-requisites not installed
#######################################
function check_for_prerequisites() {
  local error_count=0
  if ! command -v gcloud >/dev/null; then
    error "The gcloud CLI is not installed."
    echo -e "\nFollow GCP's instructions at ${BLUE}https://cloud.google.com/sdk/docs/install${ENDCOLOR} to install the gcloud CLI on your local machine.\n"

    error_count=$((error_count + 1))
  fi

  local error_count=0
  if ! command -v terraform >/dev/null; then
    error "The Terraform CLI is not installed."
    echo -e "\nFollow Terraform's instructions at ${BLUE}https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli${ENDCOLOR} to install the Terraform CLI on your local machine.\n"

    error_count=$((error_count + 1))
  fi

  if (($error_count >= 1)); then
    echo -e "\nPlease install the above pre-requisites."
    exit 1
  fi
}

#######################################
# Validate required inputs
# Arguments:
#   Bolt project id, Billing project id, Billing bigquery dataset name
# Outputs:
#   Writes error message(s) to stdout and exit in case of errors
#######################################
function validate_inputs() {
  local error_count=0

  if [[ -z "$1" ]]; then
    error "--bolt-project is not set."
    error_count=$((error_count + 1))
  else
    echo -e "\nbolt_project_id: $1"
  fi

  if [[ -z "$2" ]]; then
    error "--billing-project is not set."
    error_count=$((error_count + 1))
  else
    echo "billing_project_id: $2"
  fi

  if [[ -z "$3" ]]; then
    error "--billing-dataset is not set."
    error_count=$((error_count + 1))
  else
    echo "billing_dataset_id: $3"
  fi

  if (($error_count >= 1)); then
    error "Insufficient arguments passed. Exiting...\n"
    exit 1
  fi

}

function main() {
  check_for_prerequisites

  bolt_project_id=""
  billing_project_id=""
  billing_dataset_id=""
  while (("$#")); do
    case "$1" in
    --bolt-project)
      bolt_project_id=$2
      shift
      ;;
    --billing-project)
      billing_project_id=$2
      shift
      ;;
    --billing-dataset)
      billing_dataset_id=$2
      shift
      ;;
    *) # no other arguments are valid
      error "Unrecognized argument: $1"
      ;;
    esac
    shift
  done

  validate_inputs "$bolt_project_id" "$billing_project_id" "$billing_dataset_id"

  echo -e "\nFetching google organization id..."
  org_id=$(get_org_id)
  echo "org_id: ${org_id}"

  echo -e "\nFetching bolt cluster default service account email..."
  bolt_service_account_email=$(get_service_account_email "${bolt_project_id}")

  echo "bolt_service_account_email: ${bolt_service_account_email}"

  # -- Set up terraform ---------------------------------------------------------

  # echo $current_version >.terraform-version

  # # Check if the correct version of terraform is installed.
  # if (! command -v terraform >/dev/null || ! terraform version 2>/dev/null | grep -q "v$current_version") && ! tfenv list 2>/dev/null | grep -q $current_version; then
  #   # Install tfenv if it doesn't already exist.
  #   if ! command -v tfenv >/dev/null; then
  #     install_tfenv
  #   fi
  #   tfenv install $current_version
  # fi

  echo -e "\nInitializing Terraform..."
  terraform init

  echo -e "\nApplying Terraform..."
  echo -e "\nTerraform action plan is set to be auto approved...\n"
  terraform apply \
    -var="bolt_project_id=${bolt_project_id}" \
    -var="billing_project_id=${billing_project_id}" \
    -var="billing_dataset_id=${billing_dataset_id}" \
    -auto-approve

}

main "$@" # Entry point
