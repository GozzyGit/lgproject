resource "azurerm_storage_account" "this" {
  name = replace(lower("${var.prefix}stg"), "-", "")

  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name = "data"

  storage_account_id = azurerm_storage_account.this.id

  container_access_type = "private"
}