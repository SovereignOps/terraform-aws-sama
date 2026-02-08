provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "secondary"
  region = "me-south-1" # Bahrain as secondary
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  vpc_cidr     = "10.10.0.0/16"
  kms_key_arn  = module.security.kms_key_arn
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  region       = var.region
}

# Circular dependency resolved: security creates its own bucket.

module "identity" {
  source = "./modules/identity"

  project_name = var.project_name
  region       = var.region
}

module "data" {
  source = "./modules/data"

  project_name    = var.project_name
  region          = var.region
  create_rds      = true
  db_password     = var.db_password
  kms_key_arn     = module.security.kms_key_arn
  log_bucket_name = module.security.log_bucket_name # New output from security
}

module "compute" {
  source = "./modules/compute"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnet_ids
  kms_key_arn  = module.security.kms_key_arn
}

module "backup" {
  source = "./modules/backup"

  project_name        = var.project_name
  kms_key_arn         = module.security.kms_key_arn
  secondary_vault_arn = aws_backup_vault.secondary.arn # Create secondary vault here or in a separate module
}

resource "aws_backup_vault" "secondary" {
  provider    = aws.secondary
  name        = "${var.project_name}-backup-vault-secondary"
  kms_key_arn = aws_kms_key.secondary.arn

  tags = {
    Name           = "${var.project_name}-backup-vault-secondary"
    Classification = "Confidential"
  }
}

resource "aws_kms_key" "secondary" {
  provider                = aws.secondary
  description             = "Secondary Region Key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = {
    Name           = "${var.project_name}-kms-key-secondary"
    Classification = "Confidential"
  }
}
