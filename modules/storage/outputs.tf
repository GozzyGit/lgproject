output "storage_account_name" {
  value = azurerm_storage_account.stg.name
}

output "primary_access_key" {
  value     = azurerm_storage_account.stg.primary_access_key
  sensitive = true
}
