output "storage_account_name" {
value = azurerm_storage_account.stg.name
}

output "storage_account_id" {
value = azurerm_storage_account.stg.id
}

output "primary_access_key" {
value     = azurerm_storage_account.stg.primary_access_key
sensitive = true
}

output "container_name" {
value = azurerm_storage_container.data.name
}
