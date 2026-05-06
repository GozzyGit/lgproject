# --------------------------
# Resource Group, Storage, Key Vault
# --------------------------

module "resource_group" {
  source   = "./modules/resource_group"
  name     = local.rg_name
  location = var.location
}

module "storage" {
  source              = "./modules/storage"
  name                = local.storage_name
  resource_group_name = module.resource_group.name
  location            = var.location
}

module "key_vault" {
  source              = "./modules/key_vault"
  name                = local.kv_name
  resource_group_name = module.resource_group.name
  location            = var.location
}

data "azurerm_subscription" "primary" {}

# --------------------------
# App Service Plan for Logic App
# --------------------------
resource "azurerm_service_plan" "logic" {
  name                = "${var.name_prefix}-logic-plan"
  location            = var.location
  resource_group_name = module.resource_group.name

  os_type  = "Linux"
  sku_name = "WS1"
}

# --------------------------
# Logic App Standard
# --------------------------
resource "azurerm_logic_app_standard" "finops" {
  name                = "${var.name_prefix}-logic-finops"
  location            = var.location
  resource_group_name = module.resource_group.name
  app_service_plan_id = azurerm_service_plan.logic.id

  storage_account_name       = module.storage.name
  storage_account_access_key = module.storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    EMAIL_TO                 = var.email_to
  }
}

# --------------------------
# Role Assignment for Logic App Managed Identity
# --------------------------
resource "azurerm_role_assignment" "cost_reader" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Cost Management Reader"
  principal_id         = azurerm_logic_app_standard.finops.identity[0].principal_id
}