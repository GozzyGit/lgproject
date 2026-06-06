
variable "rg_name" {
  description = "Existing Resource Group name"
  type        = string
  default     = "dev-lgproject876"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "UK South"
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "lee.gosling876@outlook.com"
}

variable "prefix" {}
