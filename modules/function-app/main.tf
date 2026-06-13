resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-${var.environment}-plan"
  location            = var.location
  resource_group_name = var.rg_name

  os_type  = "Linux"
  sku_name = "Y1"

  tags = var.tags
}

resource "azurerm_linux_function_app" "func" {
  name                = "${var.prefix}-${var.environment}-func"
  location            = var.location
  resource_group_name = var.rg_name

  service_plan_id = azurerm_service_plan.plan.id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
