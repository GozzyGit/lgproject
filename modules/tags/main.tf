variable "environment" {}
variable "project" {}

locals {
tags = {
Environment = var.environment
ManagedBy   = "terraform"
Project     = var.project
}
}

output "tags" {
value = local.tags
}
