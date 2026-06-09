module "rg" {
  source   = "../resource-group"
  name     = var.prefix
  location = var.location
}

module "storage" {
  source   = "../storage"
  prefix   = var.prefix
  rg_name  = module.rg.name
  location = var.location
}

module "keyvault" {
  source   = "../keyvault"
  prefix   = var.prefix
  rg_name  = module.rg.name
  location = var.location
}


module "function_app" {
  source = "../function-app"

  prefix               = var.prefix
  location             = var.location
  rg_name              = module.rg.name
  storage_account_name = module.storage.name
  storage_account_key  = module.storage.primary_access_key
}