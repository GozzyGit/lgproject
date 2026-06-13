output "client_id" {
  value = azuread_application.tf.client_id
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.current.id
}
