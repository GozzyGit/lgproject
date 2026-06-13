variable "prefix" {}
variable "location" {}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}