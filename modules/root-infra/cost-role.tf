data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "cost_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Cost Management Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}