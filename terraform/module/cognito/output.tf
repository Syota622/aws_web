# basic 認証用の Cognito ユーザープール
output "basic_user_pool_arn" {
  value = aws_cognito_user_pool.basic_access.arn
}

output "basic_user_pool_client_back_id" {
  value = aws_cognito_user_pool_client.basic_access.id
}

output "basic_user_pool_domain" {
  value = aws_cognito_user_pool_domain.basic_access.domain
}
