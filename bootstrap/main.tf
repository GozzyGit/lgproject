# -------------------------
# Terraform State Resources
# -------------------------

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-rg"
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "lgprojecttfstate876"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# -------------------------
# Main Project Resources
# -------------------------

resource "azurerm_resource_group" "main" {
  name     = "lgresourcegp876"
  location = var.location
}

resource "azurerm_storage_account" "main" {
  name                     = "lgprojectstorage876"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "lgkeyvault876"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}