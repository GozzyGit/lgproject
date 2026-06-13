#!/bin/bash
set -e

echo "Building Enterprise Terraform Azure CAF structure..."

mkdir -p modules/naming modules/tags modules/resource-group modules/storage modules/keyvault modules/function-app modules/monitoring modules/root-infra envs/dev envs/prod .github/workflows

# -------------------------

# TAGS MODULE

# -------------------------

cat > modules/tags/main.tf <<'EOF'
variable "environment" {}
variable "project" {}

locals {
tags = {
Environment = var.environment
ManagedBy   = "terraform"
Project     = var.project
}
}

output "tags" {
value = local.tags
}
EOF

# -------------------------

# MONITORING MODULE

# -------------------------

cat > modules/monitoring/main.tf <<'EOF'
resource "azurerm_log_analytics_workspace" "law" {
name                = "${var.prefix}-law"
location            = var.location
resource_group_name = var.rg_name
sku                 = "PerGB2018"
retention_in_days   = 30

tags = var.tags
}

resource "azurerm_application_insights" "appi" {
name                = "${var.prefix}-appi"
location            = var.location
resource_group_name = var.rg_name
workspace_id        = azurerm_log_analytics_workspace.law.id
application_type    = "web"

tags = var.tags
}
EOF

cat > modules/monitoring/variables.tf <<'EOF'
variable "prefix" {}
variable "location" {}
variable "rg_name" {}

variable "tags" {
type = map(string)
}
EOF

cat > modules/monitoring/outputs.tf <<'EOF'
output "app_insights_name" {
value = azurerm_application_insights.appi.name
}

output "workspace_id" {
value = azurerm_log_analytics_workspace.law.id
}
EOF

# -------------------------

# ROOT INFRA UPDATE

# -------------------------

cat > modules/root-infra/main.tf <<'EOF'
module "rg" {
source = "../resource-group"
name   = module.naming.resource_group.name
location = var.location
tags   = module.tags.tags
}

module "monitoring" {
source   = "../monitoring"
prefix   = var.prefix
location = var.location
rg_name  = module.rg.name
tags     = module.tags.tags
}
EOF

# -------------------------

# DEV ENV

# -------------------------

cat > envs/dev/backend.tf <<'EOF'
terraform {
backend "azurerm" {
resource_group_name  = "tfstate-rg"
storage_account_name = "lgprojecttfstate876"
container_name       = "tfstate"
key                  = "dev.tfstate"
}
}
EOF

cat > envs/dev/variables.tf <<'EOF'
variable "prefix" {}
variable "location" {}
variable "environment" {}
EOF

# -------------------------

# PROD ENV

# -------------------------

cp envs/dev/backend.tf envs/prod/backend.tf

sed -i 's/dev.tfstate/prod.tfstate/g' envs/prod/backend.tf

cp envs/dev/variables.tf envs/prod/variables.tf

echo "Enterprise Terraform scaffold created successfully."
