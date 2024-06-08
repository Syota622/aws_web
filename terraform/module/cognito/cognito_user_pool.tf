# Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name  = "${var.pj}-user-pool-${var.env}"

  # lambda_config {
  #   pre_sign_up = "lambda.arn"
  # }

}

# User Pool Client
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "${var.pj}-user-pool-client-${var.env}"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH", # 管理者がパスワード認証を許可
    "ALLOW_REFRESH_TOKEN_AUTH",       # リフレッシュトークン認証を許可
    "ALLOW_USER_PASSWORD_AUTH",       # ユーザーパスワード認証を許可
    "ALLOW_USER_SRP_AUTH"             # ユーザーSRP認証を許可
  ]
}

# Cognito User Pool Domain
# ユーザープールのドメインを作成することで、ユーザーがログインするためのURLを提供できます。
resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = "${var.pj}-user-pool-domain-${var.env}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}
