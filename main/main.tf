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

module "logic_app" {
  source = "./modules/logic_app"

  name_prefix         = var.name_prefix
  location            = var.location
  resource_group_name = module.resource_group.name

  app_service_plan_id        = azurerm_service_plan.logic.id

  storage_account_name       = module.storage.name
  storage_account_access_key = module.storage.primary_access_key

  email_to = var.email_to
}

resource "azurerm_role_assignment" "cost_reader" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Cost Management Reader"
  principal_id         = module.logic_app.principal_id
}

resource "azurerm_service_plan" "logic" {
  name                = "${var.name_prefix}-logic-plan"
  location            = var.location
  resource_group_name = module.resource_group.name

  os_type  = "Linux"
  sku_name = "WS1"
}