# Azure Example Usage

module "azure_compliance" {
  source = "../../azure"

  resource_group_name  = "example-rg"
  location             = "uae-north"
  postgres_server_name = "example-postgres"
  storage_account_name = "examplestorage"
  admin_username       = "adminuser"
  admin_password       = "SecureP@ssw0rd!"
}
