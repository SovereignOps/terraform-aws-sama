# tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-cloudtrail-require-bucket-access-logging
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.project_name}-logs-${var.region}"
  force_destroy = var.force_destroy

  tags = {
    Name           = "${var.project_name}-logs"
    Classification = "Top Secret"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.sama_master_key.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.logs.arn
      },
      {
        Sid    = "S3AccessLogs"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "sama_master_key" {
  description             = "SAMA Compliant Master Key"
  deletion_window_in_days = 30
  enable_key_rotation     = true # HARDCODE: Auto-rotate

  tags = {
    Name           = "${var.project_name}-kms-key"
    Classification = "Confidential" # ENFORCED TAG
  }
}

resource "aws_kms_alias" "sama_master_key_alias" {
  name          = "alias/${var.project_name}-master-key"
  target_key_id = aws_kms_key.sama_master_key.key_id
}

resource "aws_cloudtrail" "sama_trail" {
  name                          = "${var.project_name}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.logs.bucket
  include_global_service_events = true # HARDCODE: Global
  enable_log_file_validation    = true # HARDCODE: Integrity Validation
  kms_key_id                    = aws_kms_key.sama_master_key.arn
  is_multi_region_trail         = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.trail_logs.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn

  tags = {
    Name           = "${var.project_name}-cloudtrail"
    Classification = "Top Secret" # ENFORCED TAG
  }
}

resource "aws_cloudwatch_log_group" "trail_logs" {
  name       = "/aws/cloudtrail/${var.project_name}"
  kms_key_id = aws_kms_key.sama_master_key.arn
}

resource "aws_iam_role" "cloudtrail_role" {
  name = "${var.project_name}-cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "cloudtrail_policy" {
  name = "${var.project_name}-cloudtrail-policy"
  role = aws_iam_role.cloudtrail_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AWSCloudTrailCreateLogStream"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream"]
        Resource = "${aws_cloudwatch_log_group.trail_logs.arn}:*"
      },
      {
        Sid      = "AWSCloudTrailPutLogEvents"
        Effect   = "Allow"
        Action   = ["logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.trail_logs.arn}:*"
      }
    ]
  })
}

resource "aws_guardduty_detector" "sama_guardduty" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = {
    Name           = "${var.project_name}-guardduty"
    Classification = "Confidential"
  }
}

resource "aws_config_configuration_recorder" "sama_config" {
  name     = "${var.project_name}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_iam_role" "config_role" {
  name = "${var.project_name}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}
