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
  vpc_id               = module.network.vpc_id
  private_subnet_c_ids = module.network.private_c_subnet_ids
  private_subnet_d_ids = module.network.private_d_subnet_ids

  # backend
  ecs_sg_id = module.backend.ecs_sg_id
}

## backend ###
module "backend" {
  source = "../../module/backend"
  pj     = var.pj
  env    = var.env

  # network
  vpc_id              = module.network.vpc_id
  public_subnet_c_ids = module.network.public_c_subnet_ids
  public_subnet_d_ids = module.network.public_d_subnet_ids

  # domain
  acm_certificate = module.domain.acm_certificate

  # database
  secrets_manager_arn = module.database.secrets_manager_arn

  # cognito
  basic_user_pool_arn = module.cognito.basic_user_pool_arn
  basic_user_pool_client_back_id = module.cognito.basic_user_pool_client_back_id
  basic_user_pool_domain = module.cognito.basic_user_pool_domain
}

## domain ###
module "domain" {
  source = "../../module/domain"
  pj     = var.pj
  env    = var.env

  # backend
  alb_dns     = module.backend.alb_dns
  alb_zone_id = module.backend.alb_zone_id
}

## cognito ###
module "cognito" {
  source = "../../module/cognito"
  pj     = var.pj
  env    = var.env
}
