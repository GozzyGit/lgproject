resource "azurerm_logic_app_standard" "finops" {
  name                = "${var.name_prefix}-logic-finops"
  location            = var.location
  resource_group_name = var.resource_group_name

  app_service_plan_id = var.app_service_plan_id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  identity {
    type = "SystemAssigned"
  }
}