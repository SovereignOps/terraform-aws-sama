output "kms_key_arn" {
  value = aws_kms_key.sama_master_key.arn
}

output "kms_key_id" {
  value = aws_kms_key.sama_master_key.key_id
}

output "log_bucket_name" {
  value = aws_s3_bucket.logs.bucket
}

output "log_bucket_arn" {
  value = aws_s3_bucket.logs.arn
}
