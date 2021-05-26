cd "$projectn_path/gcp"
login_command=$(terraform output -raw ssh_command)
test_command="$login_command --command="
ssh_command="$login_command --dry-run"
redirect_command="ssh -tt $($ssh_command | cut -c17-)"