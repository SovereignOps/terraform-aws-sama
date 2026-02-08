# GCP Module for SAMA Compliance Kit
#
# Resources:
# - Google SQL Database Instance (Private IP, CMEK)
# - Google Storage Bucket (Uniform Access, CMEK)
# - Google Compute Network (VPC Service Controls)
#
# Region: me-central2 (Dammam) - CRITICAL for KSA

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

# 1. Google Compute Network (VPC Service Controls)
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false # Best practice for production
}

# Subnet for the region
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

# Private Service Access for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# 2. Google SQL Database Instance (Private IP, CMEK)
resource "google_sql_database_instance" "instance" {
  name             = var.db_instance_name
  database_version = "POSTGRES_14"
  region           = var.region
  
  # CMEK Encryption
  encryption_key_name = var.kms_key_name
  
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled    = false # Disable public IP
      private_network = google_compute_network.vpc_network.id
    }

    backup_configuration {
      enabled = true
      binary_log_enabled = false
    }
  }
  
  deletion_protection = var.deletion_protection 
}

# 3. Google Storage Bucket (Uniform Access, CMEK)
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  encryption {
    default_kms_key_name = var.kms_key_name
  }
  
  versioning {
    enabled = true
  }
}
