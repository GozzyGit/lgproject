module "infra" {
  source = "../../modules/root-infra"

  prefix      = var.prefix
  location    = var.location
  environment = "dev"
}
