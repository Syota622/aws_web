## terraform backend ###
module "tf_backend" {
  source = "../../module/tf_backend"
  pj     = var.pj
  env    = var.env
}

## network ###
module "network" {
  source = "../../module/network"
  pj     = var.pj
  env    = var.env
}
