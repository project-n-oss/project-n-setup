# If you set a custom ssh key, then you must copy it to a file in this directory named ssh_key.pem.
if [ -n "$(terraform output -raw ssh_key)" ]; then
  rm -f ssh_key.pem
  terraform output -raw ssh_key > ssh_key.pem
fi
chmod 400 ssh_key.pem
if [ "$manual_confirm" -eq "1" ]; then
  args=""
else
  args="-oStrictHostKeyChecking=accept-new "
fi
test_command="$(terraform output -raw ssh_command) $args"
# Redirect input from /dev/tty to allow interaction after login
login_command="$test_command</dev/tty"

handle_ssh_errors() {
  echo "$1"  # Write out the error
}