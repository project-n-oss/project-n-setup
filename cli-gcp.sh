cd "$projectn_path/gcp"

# -- Ensure that the gcloud CLI is installed ----------------------------------

if ! command -v gcloud >/dev/null; then
  echo "The gcloud CLI is not installed. Follow GCP's instructions at https://cloud.google.com/sdk/docs/install to install it." 1>&2
  exit 1
fi

# -- Request a package --------------------------------------------------------

if [ "$crunch_mode" -eq "0" ]; then
  customer_profile="demo-gcp"
else
  customer_profile="crunch-gcp"
fi