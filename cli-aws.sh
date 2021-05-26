cd "$projectn_path/aws"

# -- Ensure that the AWS CLI is installed -------------------------------------

if ! command -v aws >/dev/null; then
  echo "The AWS CLI is not installed. Follow AWS's instructions at https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html to install and configure it." 1>&2
  exit 1
fi

# -- Request a package --------------------------------------------------------

if [ "$crunch_mode" -eq "0" ]; then
  customer_profile="demo-aws"
else
  customer_profile="crunch-aws"
fi