variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region (must be in KSA, e.g., me-central2)"
  type        = string
  default     = "me-central2"
}

variable "network_name" {
  description = "VPC Network Name"
  type        = string
  default     = "sama-vpc"
}

variable "db_instance_name" {
  description = "Cloud SQL Instance Name"
  type        = string
  default     = "sama-sql-instance"
}

variable "bucket_name" {
  description = "GCS Bucket Name (globally unique)"
  type        = string
  default     = "sama-gcs-bucket-unique-123"
}

variable "kms_key_name" {
  description = "KMS Key Resource Name for CMEK"
  type        = string
  default     = "projects/YOUR_PROJECT/locations/me-central2/keyRings/my-key-ring/cryptoKeys/my-key"
}

variable "deletion_protection" {
  description = "Enable deletion protection for databases"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Force destroy GCS buckets"
  type        = bool
  default     = false
}
