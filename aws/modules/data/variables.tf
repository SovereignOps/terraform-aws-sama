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
