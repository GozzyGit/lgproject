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

