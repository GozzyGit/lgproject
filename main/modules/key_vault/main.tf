resource "azurerm_key_vault" "kv" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}
   
data "azurerm_client_config" "current" {}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}
