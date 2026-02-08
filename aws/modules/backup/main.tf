resource "aws_backup_vault" "sama_vault" {
  name        = "${var.project_name}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = {
    Name           = "${var.project_name}-backup-vault"
    Classification = "Confidential"
  }
}

resource "aws_backup_plan" "sama_backup_plan" {
  name = "${var.project_name}-backup-plan"

  rule {
    rule_name         = "daily-backup-with-copy"
    target_vault_name = aws_backup_vault.sama_vault.name
    schedule          = "cron(0 5 ? * * *)" # Daily at 5am

    lifecycle {
      delete_after = 35 # Compliance retention
    }

    copy_action {
      destination_vault_arn = var.secondary_vault_arn
      lifecycle {
        delete_after = 35
      }
    }
  }

  tags = {
    Classification = "Confidential"
  }
}

resource "aws_backup_selection" "sama_selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.project_name}-backup-selection"
  plan_id      = aws_backup_plan.sama_backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}

resource "aws_iam_role" "backup_role" {
  name = "${var.project_name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
