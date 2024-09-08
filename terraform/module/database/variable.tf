# ### common ###
variable "pj" {}
variable "env" {}
variable "vpc_id" {}
variable "private_subnet_c_ids" {}
variable "private_subnet_d_ids" {}
variable "backend_ecs_sg_id" {}
variable "lambda_migrate_sg_id" {}

### Aurora Serverless ###
locals {
  aurora_cluster_name = {
    dev  = "${var.pj}-serverless-${var.env}"
    prod = "${var.pj}-serverless-${var.env}"
  }
  aurora_serverless_name = {
    dev  = "${var.pj}-serverless-writer-instance-${var.env}"
    prod = "${var.pj}-serverless-writer-instance-${var.env}"
  }
  backup_retention_period = {
    dev  = 3
    prod = 30
  }
  preferred_backup_window = {
    dev  = "18:15-19:15" # jst：03:15~04:15
    prod = "18:15-19:15" # jst：03:15~04:15
  }
  preferred_maintenance_window = {
    dev  = "mon:19:25-mon:20:25" # jst：Tuesday(04:25~05:25)
    prod = "mon:19:25-mon:20:25" # jst：Tuesday(04:25~05:25)
  }
  skip_final_snapshot = {
    dev  = true
    prod = true
  }
}

# SecretsManager(Config Confidential information: Aurora and RDS Proxy)
data "aws_secretsmanager_secret_version" "db" {

  # SecretsManager is created manually
  secret_id = "${var.pj}/aurora/serverless/${var.env}"

}

locals {
  credentials = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)
}
