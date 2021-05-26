cd "$projectn_path/aws"
test_command="$(terraform output -raw ssh_command) $args"
redirect_command="ssh -tt $(echo $test_command | cut -c4-)"

# Remove the created account from the terraform state--terraform is not able to automatically close accounts.
echo "Terraform is not able to delete AWS accounts. If you would like to delete the created account, you must do it manually."
terraform state rm 'module.account[0].aws_organizations_account.account[0]' 2>/dev/null || true