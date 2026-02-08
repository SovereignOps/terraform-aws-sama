output "auditor_role_arn" {
  value = aws_iam_role.auditor.arn
}

output "devops_admin_role_arn" {
  value = aws_iam_role.devops_admin.arn
}
