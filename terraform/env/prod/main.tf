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

## database ###
module "database" {
  source = "../../module/database"
  pj     = var.pj
  env    = var.env

  # network
  vpc_id = module.network.vpc_id
  private_subnet_c_ids = module.network.private_c_subnet_ids
  private_subnet_d_ids = module.network.private_d_subnet_ids

  # container
  ecs_sg_id = module.container.ecs_sg_id
}

## container ###
module "container" {
  source = "../../module/container"
  pj     = var.pj
  env    = var.env

  # network
  vpc_id = module.network.vpc_id
  public_subnet_c_ids = module.network.public_c_subnet_ids
  public_subnet_d_ids = module.network.public_d_subnet_ids

  # domain
  acm_certificate = module.domain.acm_certificate
}

## domain ###
module "domain" {
  source = "../../module/domain"
  pj     = var.pj
  env    = var.env

  # container
  alb_dns = module.container.alb_dns
  alb_zone_id  = module.container.alb_zone_id
}
