variable "name_prefix" {
  type        = string
  description = "Prefix for Logic App name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for Logic App"
}

variable "email_to" {
  type        = string
  description = "Email to send the report"
}