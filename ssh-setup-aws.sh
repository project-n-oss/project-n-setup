terraform output ssh_key > "$().pem"
login_command=$(terraform output -raw ssh_command)