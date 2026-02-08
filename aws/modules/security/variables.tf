variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "force_destroy" {
  description = "Force destroy S3 buckets"
  type        = bool
  default     = false
}
