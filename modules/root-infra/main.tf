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

module "dashboard" {
  source   = "../dashboard"
  prefix   = var.prefix
  rg_name  = module.rg.name
  location = var.location
}