#terraform {
#  backend "azurerm" {
#    resource_group_name  = "tfstate-rg"
#    storage_account_name = "lgprojecttfstate876"
#    container_name       = "tfstate"
#    key                  = "terraform.tfstate"
#  }
#}