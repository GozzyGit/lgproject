resource "azurerm_storage_account" "stg" {
  name                     = replace(lower("${var.prefix}${var.environment}stg"), "-", "")
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}
