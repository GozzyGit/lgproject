
############################
# Outputs
############################

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}

output "workbook_id" {
  value = azurerm_application_insights_workbook.monitoring.id
}

output "action_group_id" {
  value = azurerm_monitor_action_group.ops.id
}