output "principal_id" {
  value = azurerm_logic_app_standard.finops.identity[0].principal_id
}