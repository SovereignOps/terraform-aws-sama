# Azure Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "sama-rg"
}

variable "location" {
  description = "Azure region (uae-north or qatar-central)"
  type        = string
  default     = "uae-north"
}

variable "postgres_server_name" {
  description = "Name of the PostgreSQL Server"
  type        = string
  default     = "sama-postgres"
}

variable "admin_username" {
  description = "Administrator username for PostgreSQL"
  type        = string
  default     = "samaadmin"
}

variable "admin_password" {
  description = "Administrator password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "storage_account_name" {
  description = "Name of the Storage Account"
  type        = string
  default     = "samastorageacct"
}

variable "private_dns_zone_id" {
  description = "ID of the Private DNS Zone for PostgreSQL Flexible Server (optional)"
  type        = string
  default     = null
}
