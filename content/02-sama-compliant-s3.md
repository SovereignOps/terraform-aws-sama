---
title: "SAMA-Compliant S3 with Terraform: The Definitive Guide"
published: false
description: "Creating an S3 bucket that satisfies SAMA Cyber Security Framework requirements using Terraform (KMS, Logging, Public Access Block)."
tags: terraform, s3, security, compliance, aws
---

# SAMA-Compliant S3 with Terraform

In the Gulf, you don't just "create a bucket." An unconfigured S3 bucket is a compliance violation waiting to happen. The **Saudi Arabian Monetary Authority (SAMA)** requires specific controls for data at rest.

Here is the Terraform code to build a fully compliant S3 bucket.

## The Requirements

1.  **Encryption:** Must use **KMS (Customer Managed Keys)**, not just default SSE-S3.
2.  **Versioning:** Enable versioning for audit trails.
3.  **Public Access:** Block ALL public access.
4.  **Logging:** Enable access logging for forensics.
5.  **Retention:** Enforce lifecycle rules.

## The Terraform Code

### 1. The KMS Key (Customer Managed)

First, create the key. SAMA prefers keys you control.

```hcl
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for SAMA Compliant S3"
  deletion_window_in_days = 30
  enable_key_rotation     = true # Mandatory for compliance

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
    ]
  })
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/sama-s3-key"
  target_key_id = aws_kms_key.s3_key.key_id
}
```

### 2. The Bucket Configuration

```hcl
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "fintech-data-prod-001"
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# 1. Block Public Access (CRITICAL)
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Server-Side Encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# 3. Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 4. Access Logging
resource "aws_s3_bucket_logging" "logs" {
  bucket = aws_s3_bucket.secure_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}
```

## Why This Matters

-   **`enable_key_rotation`**: Ensures cryptographic hygiene.
-   **`block_public_acls`**: Prevents "accidental" public exposure via ACLs.
-   **`bucket_key_enabled`**: Reduces KMS costs while maintaining security.

This module is the baseline. Do not deploy S3 in production without these blocks.

---
*Repo:* [github.com/SovereignOps/terraform-aws-sama](https://github.com/SovereignOps/terraform-aws-sama)
