variable "region" {
  description = "AWS Region"
  type        = string
  default     = "me-central-1"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "sama-compliance-kit"
}

variable "db_password" {
  description = "Database Password"
  type        = string
  default     = "SuperSecretPass123!"
  sensitive   = true
}
