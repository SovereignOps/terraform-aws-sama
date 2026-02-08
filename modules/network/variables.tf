variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["me-central-1a", "me-central-1b", "me-central-1c"]
}

variable "kms_key_arn" {
  description = "KMS Key ARN for encryption"
  type        = string
}
