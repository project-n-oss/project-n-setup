login_command=$(terraform output -raw ssh_command)
test_command="$login_command --command="