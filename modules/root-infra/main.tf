module "tags" {
  source = "../tags"

  environment = var.environment
  project     = var.prefix
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
  tags     = module.tags.tags
}

module "storage" {
  source   = "../storage"
  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name
  tags     = module.tags.tags
}

module "keyvault" {
  source   = "../keyvault"
  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name
  tags     = module.tags.tags
}

module "function_app" {
  source = "../function-app"

  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name

  storage_account_name = module.storage.storage_account_name
  storage_account_key  = module.storage.primary_access_key

  tags = module.tags.tags
}

module "monitoring" {
  source   = "../monitoring"
  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name
  tags     = module.tags.tags
}
