module "resource_group" {
  source   = "./modules/resource_group"
  name     = local.rg_name
  location = var.location
}

module "storage" {
  source              = "./modules/storage"
  name                = local.storage_name
  resource_group_name = module.resource_group.name
  location            = var.location
}

module "key_vault" {
  source              = "./modules/key_vault"
  name                = local.kv_name
  resource_group_name = module.resource_group.name
  location            = var.location
}

module "cost_function" {
  source              = "./modules/cost_function"
  name                = local.func_name
  resource_group_name = module.resource_group.name
  location            = var.location

  storage_account_name       = module.storage.storage_account_name
  storage_account_access_key = module.storage.primary_access_key
}
