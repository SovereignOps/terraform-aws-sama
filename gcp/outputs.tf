output "vpc_id" {
  value = google_compute_network.vpc_network.id
}

output "db_instance_ip" {
  value = google_sql_database_instance.instance.ip_address.0.ip_address
}

output "bucket_url" {
  value = google_storage_bucket.bucket.url
}
