output "app_insights_name" {
value = azurerm_application_insights.appi.name
}

output "workspace_id" {
value = azurerm_log_analytics_workspace.law.id
}
