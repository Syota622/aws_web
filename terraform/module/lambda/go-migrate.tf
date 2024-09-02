# ECRリポジトリの作成
resource "aws_ecr_repository" "migration_repo" {
  name                 = "${var.pj}-db-migration-lambda-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.pj}-db-migration-lambda-ecr-${var.env}"
  }
}

# Lambda関数の定義
resource "aws_lambda_function" "migration_lambda" {
  function_name = "${var.pj}-db-migration-lambda-${var.env}"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 300
  memory_size   = 128

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.migration_repo.repository_url}:<image uri>" # GitHub ActionsでビルドしたイメージのURIを指定

  environment {
    variables = {
      SECRETS_MANAGER_SECRET_ARN = var.secrets_manager_arn
    }
  }

  vpc_config {
    subnet_ids         = [var.private_subnet_c_ids, var.private_subnet_d_ids]
    security_group_ids = [aws_security_group.lambda_migrate_sg.id]
  }

  tags = {
    Name = "${var.pj}-db-migration-lambda-${var.env}"
  }

  lifecycle {
    ignore_changes = [
      image_uri
    ]
  }
}

# Lambda用のセキュリティグループ
resource "aws_security_group" "lambda_migrate_sg" {
  name        = "${var.pj}-db-migration-lambda-sg-${var.env}"
  description = "Security group for DB migration Lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj}-db-migration-lambda-sg-${var.env}"
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

  tags = {
    Name = "${var.pj}-db-migration-lambda-role-${var.env}"
  }
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
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:CreateVpcEndpoint",
          "ec2:DeleteVpcEndpoints",
          "ec2:DescribeVpcEndpoints",
          "ec2:ModifyVpcEndpoint",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ]
        Resource = "*"
      }
    ]
  })
}
