output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
value = module.storage.storage_account_name
}

output "keyvault_name" {
value = module.keyvault.name
}

output "function_app_name" {
value = module.function_app.name
}


output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}