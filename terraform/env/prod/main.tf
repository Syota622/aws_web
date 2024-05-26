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

# ## database ###
# module "database" {
#   source = "../../module/database"
#   pj     = var.pj
#   env    = var.env

#   vpc_id = module.network.vpc_id
#   private_subnet_c_ids = module.network.private_c_subnet_ids
#   private_subnet_d_ids = module.network.private_d_subnet_ids
# }

## container ###
module "container" {
  source = "../../module/container"
  pj     = var.pj
  env    = var.env

  vpc_id = module.network.vpc_id
  public_subnet_c_ids = module.network.public_c_subnet_ids
  public_subnet_d_ids = module.network.public_d_subnet_ids
}
