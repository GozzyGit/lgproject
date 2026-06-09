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

<<<<<<< HEAD
module "dashboard" {
  source   = "../dashboard"
  prefix   = var.prefix
  rg_name  = module.rg.name
  location = var.location
}
=======
module "cost_report" {
  source = "../cost-report-logicapp"

  prefix   = var.prefix
  location = var.location
  rg_name  = module.rg.name
}
>>>>>>> parent of ebc4839 (fully working dev and prod with azure tfstate (waiting for manual azure delections before applying))
