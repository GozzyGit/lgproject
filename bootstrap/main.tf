resource "azurerm_resource_group" "main" {
  name     = "lgresource234"
  location = var.location
}

data "azurerm_client_config" "current" {}

# -----------------------------
# Storage Account
# -----------------------------
resource "azurerm_storage_account" "main" {
  name                     = "lgprojectstore234"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# -----------------------------
# Key Vault
# -----------------------------
resource "azurerm_key_vault" "main" {
  name                = "lgkeyvault234"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  purge_protection_enabled   = false
  soft_delete_retention_days = 7
}

# -----------------------------
# Log Analytics Workspace
# Cheapest monitoring option
# -----------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "lg-monitor-workspace"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku               = "PerGB2018"
  retention_in_days = 30
}

# -----------------------------
# Storage Monitoring
# -----------------------------
resource "azurerm_monitor_diagnostic_setting" "storage_monitoring" {
  name                       = "storage-monitoring"
  target_resource_id         = azurerm_storage_account.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }
}

# -----------------------------
# Key Vault Monitoring
# -----------------------------
resource "azurerm_monitor_diagnostic_setting" "keyvault_monitoring" {
  name                       = "keyvault-monitoring"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}