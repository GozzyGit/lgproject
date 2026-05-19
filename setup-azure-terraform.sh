#!/bin/bash

echo "Creating Azure Terraform project structure..."

# Root folders
mkdir -p bootstrap
mkdir -p modules/cost-alert
mkdir -p envs/dev
mkdir -p envs/prod

########################################
# MODULE: cost-alert
########################################

cat > modules/cost-alert/main.tf <<EOF
resource "azurerm_consumption_budget_subscription" "budget" {
  name            = var.name
  subscription_id = var.subscription_id

  amount     = var.amount
  time_grain = "Daily"

  time_period {
    start_date = var.start_date
  }

  notification {
    enabled       = true
    threshold     = var.threshold
    operator      = "GreaterThan"
    contact_emails = var.emails
  }
}
EOF

cat > modules/cost-alert/variables.tf <<EOF
variable "name" {}
variable "subscription_id" {}

variable "amount" {
  type = number
}

variable "threshold" {
  type    = number
  default = 80
}

variable "start_date" {}

variable "emails" {
  type = list(string)
}
EOF

cat > modules/cost-alert/outputs.tf <<EOF
output "budget_name" {
  value = azurerm_consumption_budget_subscription.budget.name
}
EOF

########################################
# DEV ENV
########################################

cat > envs/dev/main.tf <<EOF
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

  emails = ["REPLACE_WITH_YOUR_EMAIL"]
}
EOF

########################################
# PROD ENV
########################################

cat > envs/prod/main.tf <<EOF
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

  name            = "prod-daily-budget"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 50
  threshold  = 80
  start_date = "2026-01-01T00:00:00Z"

  emails = ["REPLACE_WITH_YOUR_EMAIL"]
}
EOF

echo "Done."
echo "Next steps:"
echo "1. cd envs/dev && terraform init"
echo "2. terraform apply"
