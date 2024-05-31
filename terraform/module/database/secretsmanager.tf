# AuroraのパスワードをSecretsManagerに保存する
resource "random_password" "password" {
  length  = 16    # パスワードの長さ
  special = false # 特殊文字を含むかどうか
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.pj}/aurora/serverless/${var.env}"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    DB_USER     = "mysql_user"
    DB_PASSWORD = random_password.password.result
    DB_NAME     = "db"
    DB_PORT     = "3306"
    DB_HOST     = aws_rds_cluster.aurora_cluster.endpoint
  })
}
