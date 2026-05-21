data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name = substr(
    replace(lower("${var.prefix}kv"), "-", ""),
    0,
    24
  )

  location            = var.location
  resource_group_name = var.rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}