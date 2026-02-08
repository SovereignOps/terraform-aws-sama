output "backup_vault_arn" {
  value = aws_backup_vault.sama_vault.arn
}

output "backup_plan_id" {
  value = aws_backup_plan.sama_backup_plan.id
}
