// Crunch mode only (not estimate savings)

locals {
  account_id = var.create_account ? aws_organizations_account.account[0].id : [for account in data.aws_organizations_organization.account_info[0].accounts : account.id if account.email == var.account_email][0]
}

// If a new account is not created, find the id of the account to use from its name
data "aws_organizations_organization" "account_info" {
  count = var.create_account ? 0 : 1
}

resource "aws_organizations_account" "account" {
  close_on_deletion = true
  count     = var.create_account ? 1 : 0
  name      = var.account_name
  email     = var.account_email
  role_name = var.organizational_iam_role_name
}

resource "null_resource" "wait_for_account" {
  count = var.create_account ? 1 : 0

  depends_on = [
    aws_organizations_account.account
  ]

  provisioner "local-exec" {
    command = <<EOF
      finished=0
      for i in `seq 1 60`; do
        # Get the credentials for a role session. This may be unavailable initially if account setup is not finished.
        if export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" $(aws --profile=${var.profile} sts assume-role --role-arn arn:aws:iam::${aws_organizations_account.account[0].id}:role/${var.organizational_iam_role_name} --role-session-name account-readiness --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --output text)); then
          finished=1
          break
        fi
        sleep 5
      done
      if [ "$finished" -eq "0" ]; then
        echo "Timeout waiting for the account to finish creating." && exit 1
      fi
      touch fake-key.pub
      finished=0
      for i in `seq 1 60`; do
        # Check that the services we need to use with the new account are enabled
        if echo "$(aws ec2 create-security-group --description "test security group" --group-name "test group" --dry-run 2>&1)" | grep -q "An error occurred (DryRunOperation) when calling the CreateSecurityGroup operation: Request would have succeeded, but DryRun flag is set." \
          && echo "$(aws ec2 import-key-pair --key-name "fake-key" --public-key-material fileb://./fake-key.pub --dry-run 2>&1)" | grep -q "An error occurred (DryRunOperation) when calling the ImportKeyPair operation: Request would have succeeded, but DryRun flag is set." \
          && aws ec2 describe-security-groups --filters Name=group-name,Values=default --query "SecurityGroups[*].[GroupId]" --max-items 1 --output text 1>/dev/null 2>/dev/null \
          && aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --max-items 1 1>/dev/null 2>/dev/null \
          && echo "$(aws ec2 revoke-security-group-egress --group-id fake-group --dry-run 2>&1)" | grep -q "An error occurred (DryRunOperation) when calling the RevokeSecurityGroupEgress operation: Request would have succeeded, but DryRun flag is set."; then
          finished=1
          break
        fi
      done
      rm fake-key.pub
      if [ "$finished" -eq "0" ]; then
        echo "Timeout waiting for the account to finish creating." && exit 1
      fi
    EOF
  }
}

