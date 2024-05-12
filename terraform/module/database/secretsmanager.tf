resource "random_password" "password" {
  length           = 16  # パスワードの長さ
  special          = true  # 特殊文字を含むかどうか
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.pj}/aurora/serverless/${var.env}"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "mysql_user"
    password = random_password.password.result
    database = "db"
  })
}
