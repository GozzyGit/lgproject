variable "environment" {}
variable "project" {}

output "tags" {
  value = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project
  }
}
