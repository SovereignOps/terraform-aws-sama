variable "compartment_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "vcn_cidr" {
  description = "VCN CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_name" {
  description = "VCN Display Name"
  type        = string
  default     = "sama-vcn"
}

variable "bucket_name" {
  description = "Bucket Name"
  type        = string
}

variable "bucket_namespace" {
  description = "Object Storage Namespace"
  type        = string
}

variable "kms_key_id" {
  description = "KMS Key ID (OCID)"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Force destroy buckets (Not directly supported by OCI provider, kept for consistency)"
  type        = bool
  default     = false
}
