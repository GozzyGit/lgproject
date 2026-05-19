terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "main" {
  name = "lgresourcegp876"
}

module "cost_alert" {
  source = "../../modules/cost-alert"

  name            = "prod-budget"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 50
  threshold  = 80
  start_date = "2026-01-01T00:00:00Z"

  emails = [
    "lee.gosling876@outlook.com"
  ]
}

module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  action_group_name = "prod-monitoring"

  email_receiver = "lee.gosling876@outlook.com"
}
