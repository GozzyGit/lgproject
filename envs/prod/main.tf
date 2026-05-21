terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

module "infra" {
  source   = "../../modules/root-infra"
  prefix   = var.prefix
  location = var.location
}
