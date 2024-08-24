# ECRリポジトリの作成
resource "aws_ecr_repository" "migration_repo" {
  name                 = "${var.pj}-db-migration-lambda-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Lambda関数の定義
resource "aws_lambda_function" "migration_lambda" {
  function_name = "${var.pj}-db-migration-lambda-${var.env}"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 300
  memory_size   = 128

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.migration_repo.repository_url}:latest"

  environment {
    variables = {
      SECRETS_MANAGER_SECRET_ID = var.secrets_manager_arn
    }
  }
}

# Lambda用のIAMロール
resource "aws_iam_role" "lambda_role" {
  name = "${var.pj}-db-migration-lambda-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda用のカスタムIAMポリシー
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.pj}-db-migration-lambda-policy-${var.env}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secrets_manager_arn
      }
    ]
  })
}
