### variable ###
variable "pj" {}
variable "env" {}

locals {
  url = {
    dev = {
      path = "https://dev.api.mokokero.com"
    },
    prod = {
      path = "https://api.mokokero.com"
    }
  }
}
