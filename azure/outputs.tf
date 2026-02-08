output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "storage_account_endpoint" {
  value = azurerm_storage_account.storage.primary_blob_endpoint
}
