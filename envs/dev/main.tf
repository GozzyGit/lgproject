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

module "cost_alert" {
  source = "../../modules/cost-alert"

  name            = "dev-daily-budget"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 10
  threshold  = 80
  start_date = "2026-01-01T00:00:00Z"

  emails = ["lee.gosling876@outlook.com"]
}
