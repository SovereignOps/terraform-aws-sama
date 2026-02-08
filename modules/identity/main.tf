# IAM Password Policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
  hard_expiry                    = false
}

# SAMA-specific Roles

# Read-Only Auditor Role
resource "aws_iam_role" "auditor" {
  name = "${var.project_name}-AuditorRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })

  tags = {
    Classification = "Top Secret"
    RoleType       = "Compliance"
  }
}

resource "aws_iam_role_policy_attachment" "auditor_policy" {
  role       = aws_iam_role.auditor.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# DevOps Admin Role (MFA required)
resource "aws_iam_role" "devops_admin" {
  name = "${var.project_name}-DevOpsAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })

  tags = {
    Classification = "Confidential"
    RoleType       = "Operations"
  }
}

resource "aws_iam_role_policy_attachment" "devops_policy" {
  role       = aws_iam_role.devops_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_caller_identity" "current" {}
