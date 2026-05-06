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

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    EMAIL_TO                 = var.email_to
  }
}

output "principal_id" {
  value       = azurerm_logic_app_standard.finops.identity[0].principal_id
  description = "Principal ID of the system-assigned identity"
}

output "logic_app_id" {
  value       = azurerm_logic_app_standard.finops.id
  description = "Logic App Standard ID"
}

output "logic_app_name" {
  value       = azurerm_logic_app_standard.finops.name
  description = "Logic App Standard name"
}