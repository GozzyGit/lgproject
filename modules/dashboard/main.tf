
############################
# Data Sources
############################

data "azurerm_subscription" "current" {}

############################
# Log Analytics Workspace
############################

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${replace(var.rg_name, "-", "")}law"
  location            = var.location
  resource_group_name = var.rg_name

  sku               = "PerGB2018"
  retention_in_days = 30
}

############################
# Action Group
############################

resource "azurerm_monitor_action_group" "ops" {
  name                = "ag-operations"
  resource_group_name = var.rg_name
  short_name          = "ops"

  email_receiver {
    name          = "operations"
    email_address = var.alert_email
  }
}

############################
# Resource Group Activity Alert
############################

resource "azurerm_monitor_activity_log_alert" "resource_group_changes" {
  name                = "resource-group-changes"
  resource_group_name = var.rg_name
  location            = "westeurope"

  scopes = [
    "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.rg_name}"
  ]

  criteria {
    category = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}

############################
# Azure Monitor Workbook
############################

resource "azurerm_application_insights_workbook" "monitoring" {
  name                = uuid()
  location            = var.location
  resource_group_name = var.rg_name

  display_name = "${var.rg_name} Monitoring"

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "# ${var.rg_name} Monitoring Workbook"
        }
      }
    ]
    isLocked = false
  })
}
