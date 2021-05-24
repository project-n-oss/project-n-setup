  echo "crunch_mode=false" >> $var_file  # only estimate savings for now
  echo "manage_vpc=false" >> $var_file  # this only matters in crunch mode
  echo "ssh_access_cidrs=[]" >> $var_file  # this only matters in crunch mode
  echo "region=\"$(aws configure get region)\"" >> $var_file
  read -rp "AWS profile to use (can be \"default\"): " profile
  echo "profile=\"$profile\"" >> $var_file
  read -rp "Name of the key pair to create to use with the login server: " key_name
  echo "key_name=\"$key_name\"" >> $var_file