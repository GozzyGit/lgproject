data "azurerm_subscription" "current" {}

# -------------------------
# Terraform State Resources
# -------------------------



resource "azuread_application" "tf" {
  display_name = "terraform-github-actions"
}

resource "azuread_service_principal" "tf" {
  client_id = azuread_application.tf.client_id
}

resource "azuread_application_federated_identity_credential" "github" {
  application_id = azuread_application.tf.id

  display_name = "github-oidc"

  issuer    = "https://token.actions.githubusercontent.com"
  audiences = ["api://AzureADTokenExchange"]

  subject = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "rbac" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.tf.object_id
}
