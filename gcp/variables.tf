# GCP Variables

variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP Region"
  type        = string
  default     = "me-central2"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "sama-vpc"
}

variable "db_instance_name" {
  description = "Name of the SQL Database Instance"
  type        = string
  default     = "sama-sql-instance"
}

variable "bucket_name" {
  description = "Name of the Storage Bucket"
  type        = string
  default     = "sama-storage-bucket"
}

variable "kms_key_name" {
  description = "The KMS Key Name for CMEK (projects/[PROJECT_ID]/locations/[LOCATION]/keyRings/[KEY_RING]/cryptoKeys/[KEY_NAME])"
  type        = string
}
