variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "location" {
  description = "Azure Region (e.g., uae-north)"
  type        = string
  default     = "uae-north"
}

variable "postgres_server_name" {
  description = "PostgreSQL Flexible Server Name"
  type        = string
}

variable "admin_username" {
  description = "DB Admin Username"
  type        = string
}

variable "admin_password" {
  description = "DB Admin Password"
  type        = string
  sensitive   = true
}

variable "storage_account_name" {
  description = "Storage Account Name (unique)"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for Postgres"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection (locks) for resources"
  type        = bool
  default     = true
}
