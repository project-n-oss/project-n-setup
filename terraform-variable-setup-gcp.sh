  # TODO what happens if the gcloud components update thing interrupts?
  echo "current_project=\"$(gcloud config get-value project)\"" >> $var_file
  echo "zone=\"$(gcloud config get-value compute/zone)\"" >> $var_file