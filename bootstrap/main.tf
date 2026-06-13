data "azurerm_subscription" "current" {}

# -------------------------
# Terraform State Resources
# -------------------------

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-rg"
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "lgprojecttfstate876"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}


resource "azuread_application" "tf" {
  display_name = "terraform-github-actions"
}

resource "azuread_service_principal" "tf" {
  client_id = azuread_application.tf.client_id
}

resource "azuread_application_federated_identity_credential" "github" {
  application_object_id = azuread_application.tf.object_id

  display_name = "github-oidc"

  issuer   = "https://token.actions.githubusercontent.com"
  audiences = ["api://AzureADTokenExchange"]

  subject = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "rbac" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.tf.object_id
}
