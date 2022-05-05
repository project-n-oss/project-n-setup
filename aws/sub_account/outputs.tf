output "account_id" {
  value       = local.account_id
  description = "The AWS account ID for the Project N account"
}

output "role_arn" {
  value       = "arn:aws:iam::${local.account_id}:role/${var.organizational_iam_role_name}"
  description = "The AWS account ID for the Project N account"
}