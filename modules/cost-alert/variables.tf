variable "name" {}
variable "subscription_id" {}

variable "amount" {
  type = number
}

variable "threshold" {
  type    = number
  default = 80
}

variable "start_date" {}

variable "emails" {
  type = list(string)
}
