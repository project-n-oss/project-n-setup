match='export PATH=~/.local/bin:\$PATH'
until eval "$test_command'grep -q '\''$match'\'' /home/ec2-user/.bash_profile'" 2> log
do
  handle_ssh_errors "$(cat log)"
  echo "Waiting for the AWS CLI to finish updating..."
  sleep 10
done

rm log

redirect_command="ssh -tt $(echo $test_command | cut -c4-)"

if [ "$manual_confirm" -eq "1" ]; then
  read -rp "Deploy Project N? (Y/N) " deploy_confirm
  if ! [[ "$deploy_confirm" == "Y" || "$deploy_confirm" == "y" ]]; then
    no_deploy=1
    echo "Run \`projectn deploy\` from the admin server to deploy."
    if [ "$add_crunch" -eq "1" ] && [ -n "$custom_domain" ]; then
      echo "After that, run \`projectn deploy --custom_domain=$custom_domain\` to configure HTTPS."
    fi
  fi
fi

# Deploy Project N
if [ "$no_deploy" -eq "0" ]; then
  echo "projectn deploy; exit 0" | $redirect_command
  # If applicable, configure custom domain
  if [ -n "$custom_domain" ]; then
    echo "projectn deploy --custom_domain=$custom_domain; exit 0" | $redirect_command
    read -rp "Continue when you have updated the DNS records. " dns_confirm
  fi
  if [ "$convert" -eq "1" ]; then
    echo "projectn update; exit 0" | $redirect_command
  fi
fi