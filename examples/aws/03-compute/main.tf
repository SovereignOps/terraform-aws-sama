provider "aws" {
  region = "me-central-1"
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../01-network/terraform.tfstate"
  }
}

data "terraform_remote_state" "data" {
  backend = "local"
  config = {
    path = "../02-data/terraform.tfstate"
  }
}

module "compute" {
  source = "../../../aws/modules/compute"

  project_name = "example-prod"
  vpc_id       = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids   = data.terraform_remote_state.network.outputs.private_subnet_ids
  kms_key_arn  = data.terraform_remote_state.network.outputs.kms_key_arn
  
  # Example: Access data outputs if needed
  # db_endpoint = data.terraform_remote_state.data.outputs.db_endpoint
}
