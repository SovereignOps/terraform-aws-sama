provider "aws" {
  region = "me-central-1"
}

module "security" {
  source = "../../../aws/modules/security"

  project_name = "example-prod"
  region       = "me-central-1"
}

module "network" {
  source = "../../../aws/modules/network"

  project_name = "example-prod"
  vpc_cidr     = "10.0.0.0/16"
  kms_key_arn  = module.security.kms_key_arn
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "kms_key_arn" {
  value = module.security.kms_key_arn
}

output "log_bucket_name" {
  value = module.security.log_bucket_name
}
