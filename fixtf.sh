#!/bin/bash
set -e

echo "🚀 Creating FULL Azure Terraform Platform (dev + prod + OIDC + modules)..."


# FOLDERS
# =========================
mkdir -p \
  bootstrap \
  modules/{root-infra,storage,keyvault,function-app,monitoring,tags} \
  envs/{dev,prod} \
  .github/workflows

# =========================
# PROVIDERS (ROOT IDEA)
# =========================
cat > bootstrap/providers.tf <<'EOF'
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" { features {} }
provider "azuread" {}
EOF

# =========================
# BOOTSTRAP OIDC (FULL)
# =========================
cat > bootstrap/main.tf <<'EOF'
data "azurerm_subscription" "current" {}

resource "azuread_application" "tf" {
  display_name = "terraform-github-actions"
}

resource "azuread_service_principal" "tf" {
  client_id = azuread_application.tf.client_id
}

resource "azuread_federated_identity_credential" "github" {
  application_id = azuread_application.tf.id

  display_name = "github-oidc"

  issuer   = "https://token.actions.githubusercontent.com"
  audience = ["api://AzureADTokenExchange"]

  subject = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "rbac" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.tf.object_id
}
EOF

cat > bootstrap/variables.tf <<'EOF'
variable "github_org" {}
variable "github_repo" {}
EOF

cat > bootstrap/outputs.tf <<'EOF'
output "client_id" {
  value = azuread_application.tf.client_id
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.current.id
}
EOF

# =========================
# TAGS MODULE
# =========================
cat > modules/tags/main.tf <<'EOF'
variable "environment" {}
variable "project" {}

output "tags" {
  value = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project
  }
}
EOF

# =========================
# ROOT INFRA (FULL ORCHESTRATION)
# =========================
cat > modules/root-infra/main.tf <<'EOF'
module "tags" {
  source = "../tags"

  environment = var.environment
  project     = var.prefix
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
  tags     = module.tags.tags
}

module "storage" {
  source   = "../storage"
  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name
  tags     = module.tags.tags
}

module "keyvault" {
  source   = "../keyvault"
  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name
  tags     = module.tags.tags
}

module "function_app" {
  source = "../function-app"

  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name

  storage_account_name = module.storage.storage_account_name
  storage_account_key  = module.storage.primary_access_key

  tags = module.tags.tags
}

module "monitoring" {
  source   = "../monitoring"
  prefix   = var.prefix
  location = var.location
  rg_name  = azurerm_resource_group.rg.name
  tags     = module.tags.tags
}
EOF

cat > modules/root-infra/variables.tf <<'EOF'
variable "prefix" {}
variable "location" {}
variable "environment" {}
EOF

# =========================
# STORAGE
# =========================
cat > modules/storage/main.tf <<'EOF'
resource "azurerm_storage_account" "stg" {
  name                     = replace(lower("${var.prefix}${var.environment}stg"), "-", "")
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}
EOF

cat > modules/storage/variables.tf <<'EOF'
variable "prefix" {}
variable "rg_name" {}
variable "location" {}
variable "tags" {
  type = map(string)
}
EOF

cat > modules/storage/outputs.tf <<'EOF'
output "storage_account_name" {
  value = azurerm_storage_account.stg.name
}

output "primary_access_key" {
  value     = azurerm_storage_account.stg.primary_access_key
  sensitive = true
}
EOF

# =========================
# KEYVAULT
# =========================
cat > modules/keyvault/main.tf <<'EOF'
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name = substr(replace(lower("${var.prefix}${var.environment}kv"), "-", ""), 0, 24)

  location            = var.location
  resource_group_name = var.rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = true

  tags = var.tags
}
EOF

cat > modules/keyvault/variables.tf <<'EOF'
variable "prefix" {}
variable "rg_name" {}
variable "location" {}
variable "tags" {
  type = map(string)
}
EOF

# =========================
# FUNCTION APP
# =========================
cat > modules/function-app/main.tf <<'EOF'
resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-${var.environment}-plan"
  location            = var.location
  resource_group_name = var.rg_name

  os_type  = "Linux"
  sku_name = "Y1"

  tags = var.tags
}

resource "azurerm_linux_function_app" "func" {
  name                = "${var.prefix}-${var.environment}-func"
  location            = var.location
  resource_group_name = var.rg_name

  service_plan_id = azurerm_service_plan.plan.id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
EOF

cat > modules/function-app/variables.tf <<'EOF'
variable "prefix" {}
variable "location" {}
variable "rg_name" {}
variable "storage_account_name" {}
variable "storage_account_key" {
  sensitive = true
}
variable "tags" {
  type = map(string)
}
EOF

# =========================
# MONITORING
# =========================
cat > modules/monitoring/main.tf <<'EOF'
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-${var.environment}-law"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
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

# =========================
# DEV ENV
# =========================
cat > envs/dev/main.tf <<'EOF'
module "infra" {
  source = "../../modules/root-infra"

  prefix      = var.prefix
  location    = var.location
  environment = "dev"
}
EOF

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

cat > envs/dev/terraform.tfvars <<'EOF'
prefix   = "lgproject"
location = "westeurope"
EOF

# =========================
# PROD ENV
# =========================
cat > envs/prod/main.tf <<'EOF'
module "infra" {
  source = "../../modules/root-infra"

  prefix      = var.prefix
  location    = var.location
  environment = "prod"
}
EOF

cat > envs/prod/backend.tf <<'EOF'
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "lgprojecttfstate876"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
  }
}
EOF

cat > envs/prod/terraform.tfvars <<'EOF'
prefix   = "lgproject"
location = "westeurope"
EOF

# =========================
# GITHUB ACTIONS
# =========================
cat > .github/workflows/terraform.yml <<'EOF'
name: Terraform CI/CD

on:
  pull_request:
  push:
    branches: [ "main" ]

jobs:
  plan:
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: envs/dev

    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - uses: hashicorp/setup-terraform@v3

      - run: terraform init
      - run: terraform fmt -check
      - run: terraform validate
      - run: terraform plan -no-color
EOF

echo "✅ FULL PLATFORM READY (dev + prod + OIDC + modules + CI/CD)"
