resource "azurerm_service_plan" "this" {
  name                = "${var.prefix}-func-plan"
  location            = var.location
  resource_group_name = var.rg_name

  os_type  = "Linux"
  sku_name = "Y1" # Consumption
}


resource "azurerm_linux_function_app" "this" {
  name                = "${var.prefix}-func"
  location            = var.location
  resource_group_name = var.rg_name

  service_plan_id = azurerm_service_plan.this.id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key

  site_config {}

  identity {
    type = "SystemAssigned"
  }
}


