### variable ###
variable "pj" {}
variable "env" {}
variable "alb_dns" {}

locals {
  basic_callback_urls = {
    dev  = "https://dev-mokokero.learn.com/oauth2/idpresponse"
    prod = "https://mokokero.learn.com/oauth2/idpresponse"
  }
}
