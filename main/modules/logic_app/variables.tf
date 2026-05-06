variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "app_service_plan_id" {
  type        = string
  description = "ID of the App Service Plan"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the existing storage account"
}

variable "storage_account_access_key" {
  type        = string
  description = "Access key for the storage account"
}

variable "email_to" {
  type        = string
  description = "Email address to send the cost report"
}