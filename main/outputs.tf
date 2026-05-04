output "resource_group_name" {
  value = module.resource_group.name
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}