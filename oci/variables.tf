# OCI Variables

variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

variable "region" {
  description = "OCI Region (me-jeddah-1 or me-riyadh-1)"
  type        = string
  default     = "me-jeddah-1"
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_name" {
  description = "Name of the VCN"
  type        = string
  default     = "sama-vcn"
}

variable "bucket_name" {
  description = "Name of the Object Storage Bucket"
  type        = string
  default     = "sama-bucket"
}

variable "bucket_namespace" {
  description = "Namespace for the bucket"
  type        = string
}

variable "kms_key_id" {
  description = "The OCID of the KMS Key (optional, defaults to Oracle-managed)"
  type        = string
  default     = null
}
