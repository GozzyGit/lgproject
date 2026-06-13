resource "azurerm_storage_account" "stg" {
name = replace(lower("${var.prefix}stg"), "-", "")

resource_group_name      = var.rg_name
location                 = var.location
account_tier             = "Standard"
account_replication_type = "LRS"

tags = var.tags
}

resource "azurerm_storage_container" "data" {
name = "data"

storage_account_id = azurerm_storage_account.stg.id

container_access_type = "private"
}
