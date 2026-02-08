# RDS Instance
resource "aws_db_instance" "sama_db" {
  count                           = var.create_rds ? 1 : 0
  identifier                      = "${var.project_name}-db"
  allocated_storage               = 20
  storage_type                    = "gp3"
  engine                          = "postgres"
  engine_version                  = "14.7"
  instance_class                  = "db.t3.micro"
  db_name                         = "samadb"
  username                        = "dbadmin"
  password                        = var.db_password # Ideally from Secrets Manager, but variable for now
  parameter_group_name            = "default.postgres14"
  skip_final_snapshot             = false # COMPLIANCE: Must snapshot
  final_snapshot_identifier       = "${var.project_name}-final-snapshot"
  storage_encrypted               = true            # HARDCODE
  kms_key_id                      = var.kms_key_arn # REQUIRED
  backup_retention_period         = 35              # COMPLIANCE: Long retention
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  multi_az                        = true # COMPLIANCE: High Availability
  deletion_protection             = true
  iam_database_authentication_enabled = true
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = var.kms_key_arn

  tags = {
    Name           = "${var.project_name}-rds"
    Classification = "Confidential"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "sama_data_bucket" {
  bucket = "${var.project_name}-data-${var.region}"

  tags = {
    Name           = "${var.project_name}-s3"
    Classification = "Confidential"
  }
}

resource "aws_s3_bucket_versioning" "sama_versioning" {
  bucket = aws_s3_bucket.sama_data_bucket.id
  versioning_configuration {
    status = "Enabled" # HARDCODE
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sama_encryption" {
  bucket = aws_s3_bucket.sama_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "sama_logging" {
  bucket = aws_s3_bucket.sama_data_bucket.id

  target_bucket = var.log_bucket_name
  target_prefix = "s3-access-logs/"
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.sama_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
