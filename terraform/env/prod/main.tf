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
  backend_ecs_sg_id = module.backend.backend_ecs_sg_id

  # lambda
  lambda_migrate_sg_id = module.lambda.lambda_migrate_sg_id
}

## alb ###
module "alb" {
  source = "../../module/alb"
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
  basic_user_pool_arn            = module.cognito.basic_user_pool_arn
  basic_user_pool_client_back_id = module.cognito.basic_user_pool_client_back_id
  basic_user_pool_domain         = module.cognito.basic_user_pool_domain
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

  # # domain
  # acm_certificate = module.domain.acm_certificate

  # database
  secrets_manager_arn = module.database.secrets_manager_arn

  # security group
  alb_sg_id = module.alb.alb_sg_id

  # target group
  backend_ecs_tg = module.alb.backend_ecs_tg

  # # cognito
  # basic_user_pool_arn            = module.cognito.basic_user_pool_arn
  # basic_user_pool_client_back_id = module.cognito.basic_user_pool_client_back_id
  # basic_user_pool_domain         = module.cognito.basic_user_pool_domain
}

# ## frontend ###
# module "frontend" {
#   source = "../../module/frontend"
#   pj     = var.pj
#   env    = var.env

#   # network
#   vpc_id              = module.network.vpc_id
#   public_subnet_c_ids = module.network.public_c_subnet_ids
#   public_subnet_d_ids = module.network.public_d_subnet_ids

#   # domain
#   acm_certificate = module.domain.acm_certificate

#   # cognito
#   basic_user_pool_arn            = module.cognito.basic_user_pool_arn
#   basic_user_pool_client_back_id = module.cognito.basic_user_pool_client_back_id
#   basic_user_pool_domain         = module.cognito.basic_user_pool_domain
# }

## domain ###
module "domain" {
  source = "../../module/domain"
  pj     = var.pj
  env    = var.env

  # alb
  alb_dns     = module.alb.alb_dns
  alb_zone_id = module.alb.alb_zone_id

  # frontend
  # frontend_alb_dns     = module.frontend.frontend_alb_dns
  # frontend_alb_zone_id = module.frontend.frontend_alb_zone_id
}

## cognito ###
module "cognito" {
  source = "../../module/cognito"
  pj     = var.pj
  env    = var.env

  # alb
  alb_dns = module.alb.alb_dns
}

## lambda ###
module "lambda" {
  source = "../../module/lambda"
  pj     = var.pj
  env    = var.env

  # network
  vpc_id               = module.network.vpc_id
  private_subnet_c_ids = module.network.private_c_subnet_ids
  private_subnet_d_ids = module.network.private_d_subnet_ids

  # secretsmanager
  secrets_manager_arn = module.database.secrets_manager_arn

}
