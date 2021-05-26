rm -f ssh_key.pem
terraform output -raw ssh_key > key.pem
chmod 400 key.pem
test_command="$(terraform output -raw ssh_command) "
# redirect input from /dev/tty to allow interaction after login
login_command="$test_command</dev/tty"
