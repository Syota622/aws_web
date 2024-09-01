# ### common ###
variable "pj" {}
variable "env" {}
variable "vpc_id" {}
variable "private_subnet_c_ids" {}
variable "private_subnet_d_ids" {}
variable "secrets_manager_arn" {}

# Secrets Managerからシークレットを取得するためのデータソース
data "aws_secretsmanager_secret" "db_secret" {
  arn = var.secrets_manager_arn
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

locals {
  db_secret = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)
}
