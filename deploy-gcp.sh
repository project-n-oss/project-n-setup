ssh_command="$login_command --dry-run"
redirect_command="ssh -tt $($ssh_command | cut -c17-)"

if [ "$manual_confirm" -eq "1" ]; then
  read -rp "Deploy Project N? (Y/N) " deploy_confirm
  if ! [[ "$deploy_confirm" == "Y" || "$deploy_confirm" == "y" ]]; then
    no_deploy=1
    if [ "$add_crunch" -eq "1" ] && [ -n "$custom_domain" ]; then
      echo "Run \`projectn deploy --custom_domain=$custom_domain\` from the admin server to deploy Project N and configure HTTPS."
    else
      echo "Run \`projectn deploy\` from the admin server to deploy Project N."
    fi
  fi
fi

# Deploy Project N and configure custom domain if applicable
if [ "$no_deploy" -eq "0" ]; then
  if [ -n "$custom_domain" ]; then
    echo "projectn deploy --custom_domain=$custom_domain; exit 0" | $redirect_command
    read -rp "Continue when you have updated the DNS records. " dns_confirm
  else
    if [ "$convert" -eq "0" ]; then
      echo "projectn deploy; exit 0" | $redirect_command
    fi
  fi

  if [ "$convert" -eq "1" ]; then
    echo "projectn update; exit 0" | $redirect_command
  fi
fi