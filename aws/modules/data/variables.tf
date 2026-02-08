variable "create_rds" {
  type    = bool
  default = false
}

variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "kms_key_arn" {
  type = string
}

variable "log_bucket_name" {
  type = string
}

variable "force_destroy" {
  description = "Force destroy S3 buckets"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection for databases"
  type        = bool
  default     = true
}

variable "buckets" {
  description = "Map of buckets to create"
  type        = map(object({
    suffix     = string
    versioning = bool
  }))
  default = {
    data = {
      suffix     = "data"
      versioning = true
    }
  }
}
