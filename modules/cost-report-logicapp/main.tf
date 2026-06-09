data "azurerm_subscription" "current" {}

# -------------------------
# OFFICE 365 CONNECTION
# -------------------------

resource "azurerm_resource_group_template_deployment" "office365_connection" {
  name                = "office365-conn"
  resource_group_name = var.rg_name
  deployment_mode     = "Incremental"

  template_content = file("${path.module}/office365.json")
}

# -------------------------
# LOGIC APP
# -------------------------

resource "azurerm_resource_group_template_deployment" "logicapp" {
  name                = "cost-report-logicapp"
  resource_group_name = var.rg_name
  deployment_mode     = "Incremental"

  template_content = file("${path.module}/workflow.json")

  parameters_content = jsonencode({
    logicAppName = { value = "cost-report" }
    location     = { value = var.location }
    devRg        = { value = var.rg_name }
    prodRg       = { value = var.rg_name }

    "$connections" = {
      value = {
        office365 = {
          connectionId = "/subscriptions/${data.azurerm_subscription.current.id}/resourceGroups/${var.rg_name}/providers/Microsoft.Web/connections/office365"
          connectionName = "office365"
          id = "/subscriptions/${data.azurerm_subscription.current.id}/providers/Microsoft.Web/locations/${var.location}/managedApis/office365"
        }
      }
    }
  })
}