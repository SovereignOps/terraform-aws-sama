variable "project_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}
