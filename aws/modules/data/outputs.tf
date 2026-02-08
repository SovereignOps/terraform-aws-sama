output "rds_endpoint" {
  value = var.create_rds ? aws_db_instance.sama_db[0].endpoint : ""
}

output "s3_bucket_name" {
  value = aws_s3_bucket.sama_data_bucket.bucket
}
