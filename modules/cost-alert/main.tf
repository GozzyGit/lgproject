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
