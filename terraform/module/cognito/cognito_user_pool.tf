### Cognito ###
# Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name  = "${var.pj}-user-pool-${var.env}"

  lambda_config {
    pre_sign_up = aws_lambda_function.signup_lambda.arn
  }

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

### Lambda ###
# IAM role
resource "aws_iam_role" "user_signup_lambda_role" {
  name  = "${var.pj}-user-signup-lambda-role-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  })
}

# IAM Policy
resource "aws_iam_role_policy" "user_signup_lambda_policy" {
  name  = "${var.pj}-user-signup-lambda-policy-${var.env}"
  role  = aws_iam_role.user_signup_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/node/learn_user_ref.js"
  output_path = "${path.module}/node/learn_user_ref.zip"
}

# Lambda function
resource "aws_lambda_function" "signup_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.pj}-user-signup-lambda-${var.env}"
  role             = aws_iam_role.user_signup_lambda_role.arn
  handler          = "learn_user_ref.handler"
  runtime          = "nodejs20.x"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
}

# Lambda permission
resource "aws_lambda_permission" "allow_cognito_invoke" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup_lambda.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn
}
