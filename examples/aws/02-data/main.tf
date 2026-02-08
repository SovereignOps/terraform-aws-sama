provider "aws" {
  region = "me-central-1"
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../01-network/terraform.tfstate"
  }
}

module "data" {
  source = "../../../aws/modules/data"

  project_name    = "example-prod"
  region          = "me-central-1"
  create_rds      = true
  db_password     = "SuperSecretPass123!" # Use variables in real usage
  kms_key_arn     = data.terraform_remote_state.network.outputs.kms_key_arn
  log_bucket_name = data.terraform_remote_state.network.outputs.log_bucket_name
  
  buckets = {
    uploads = {
      suffix     = "uploads"
      versioning = true
    }
    reports = {
      suffix     = "reports"
      versioning = true
    }
  }
}
