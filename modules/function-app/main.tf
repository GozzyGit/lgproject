resource "azurerm_service_plan" "this" {
  name                = "${var.prefix}-func-plan"
  location            = var.location
  resource_group_name = var.rg_name

  os_type  = "Linux"
  sku_name = "Y1"
}

resource "azurerm_linux_function_app" "this" {
  name                = "${var.prefix}-func"
  location            = var.location
  resource_group_name = var.rg_name

  service_plan_id = azurerm_service_plan.this.id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"

    # IMPORTANT (prevents weird startup issues)
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "cost_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Cost Management Reader"
  principal_id         = azurerm_linux_function_app.this.identity[0].principal_id
}