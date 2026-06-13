variable "prefix" {}
variable "location" {}
variable "rg_name" {}
variable "storage_account_name" {}
variable "storage_account_key" {
  sensitive = true
}
variable "tags" {
  type = map(string)
}
