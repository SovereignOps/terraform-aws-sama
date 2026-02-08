variable "region" {
  description = "AWS Region (defaults to me-central-1)"
  type        = string
  default     = "me-central-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}
