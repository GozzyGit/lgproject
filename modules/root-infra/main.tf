module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"

  suffix = [var.prefix, var.environment]
}

module "tags" {
  source = "../tags"

  environment = var.environment
  project     = var.prefix
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name
  location = var.location

  tags = module.tags.tags
}

# -------------------------
# STORAGE
# -------------------------
module "storage" {
  source   = "../storage"

  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name

  tags = module.tags.tags
}

# -------------------------
# KEY VAULT
# -------------------------
module "keyvault" {
  source   = "../keyvault"

  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name

  tags = module.tags.tags
}

# -------------------------
# FUNCTION APP
# -------------------------
module "function_app" {
  source = "../function-app"

  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name

  storage_account_name = module.storage.storage_account_name
  storage_account_key  = module.storage.primary_access_key

  tags = module.tags.tags
}

# -------------------------
# MONITORING
# -------------------------
module "monitoring" {
  source   = "../monitoring"

  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name

  tags = module.tags.tags
}