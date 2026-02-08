# OCI Module for SAMA Compliance Kit
#
# Resources:
# - OCI VCN (Virtual Cloud Network)
# - OCI Object Storage Bucket
#
# Region: me-jeddah-1 or me-riyadh-1

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0.0"
    }
  }
}

# 1. OCI VCN
resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = var.vcn_name
  dns_label      = "samavcn"

  # Ensure VCN is created in the correct region (usually passed via provider, but can be explicit if multi-region setup)
}

# Internet Gateway (Optional, often needed for public access, but strict compliance might omit)
resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "internet-gateway"
  enabled        = true
}

# Route Table
resource "oci_core_route_table" "rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "default-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig.id
  }
}

# Subnet
resource "oci_core_subnet" "subnet" {
  cidr_block     = cidrsubnet(var.vcn_cidr, 8, 1)
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "subnet-1"
  dns_label      = "subnet1"
  route_table_id = oci_core_route_table.rt.id

  # Security List (allow internal traffic)
  security_list_ids = [oci_core_vcn.vcn.default_security_list_id]
}


# 2. OCI Object Storage Bucket
resource "oci_objectstorage_bucket" "bucket" {
  compartment_id = var.compartment_id
  name           = var.bucket_name
  namespace      = var.bucket_namespace

  # Encryption: OCI encrypts by default. 
  # Customer Managed Keys (KMS) can be specified via kms_key_id.
  kms_key_id = var.kms_key_id

  access_type = "NoPublicAccess" # Critical for compliance

  versioning = "Enabled"

  storage_tier = "Standard"
}
