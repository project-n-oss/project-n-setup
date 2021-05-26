login_command=$(terraform output -raw ssh_command)
test_command="$login_command --command="

handle_ssh_errors() {
  if echo "$1" | grep -q "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"; then
    ssh-keygen -R "compute.$(terraform output -raw admin_id)" -f $HOME/.ssh/google_compute_known_hosts
  else
    echo "$1"
  fi
}