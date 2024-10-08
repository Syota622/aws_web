### ECS IAM Execution Role ###
resource "aws_iam_role" "backend_ecs_execution_role" {
  name = "${var.pj}_backend_ecs_execution_role_${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "backend_ecs_execution_role" {

  name = "${var.pj}-backend-ecs-execution-policy-${var.env}"
  role = aws_iam_role.backend_ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt",
          "s3:*"
        ],
        Resource = "*"
      }
    ]
  })
}

### ECS IAM Execution Role ###
resource "aws_iam_role" "backend_ecs_task_role" {
  name = "${var.pj}_backend_ecs_task_role_${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_role" {

  name = "${var.pj}-backend-ecs-task-policy-${var.env}"
  role = aws_iam_role.backend_ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "cognito-identity:*",
          "cognito-idp:*",
          "s3:*"
        ],
        Resource = "*"
      }
    ]
  })
}
