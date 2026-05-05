resource "azurerm_storage_account" "sa" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sqldata" {
  name                 = "sqldata"
  storage_account_id = azurerm_storage_account.sa.id
}

resource "azurerm_storage_container" "webdata" {
  name                 = "webdata"
  storage_account_id = azurerm_storage_account.sa.id
}

resource "azurerm_storage_container" "logs" {
  name                 = "logs"
  storage_account_id = azurerm_storage_account.sa.id
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "primary_access_key" {
  value     = azurerm_storage_account.sa.primary_access_key
  sensitive = true
}
