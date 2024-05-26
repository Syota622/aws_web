# AWSアカウントIDを取得
data "aws_caller_identity" "self" {}

### ECS Cluster ###
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.pj}-ecs-cluster-${var.env}"
}

### ECS Task Definition ###
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.pj}-task-definition-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([{
    name  = "${var.pj}-container-${var.env}",
    image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.pj}-private-repository:latest",
    portMappings = [{
      containerPort = 8080,
      hostPort      = 8080
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

### ECS Service ###
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.pj}-ecs-service-${var.env}"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  launch_type     = "FARGATE"

  # ECS Exec(Fargate Connection)
  enable_execute_command = true

  desired_count = 0

  network_configuration {
    subnets          = [var.public_subnet_c_ids, var.public_subnet_d_ids]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.ecs_tg.arn
  #   container_name   = "${var.pj}-container-${var.env}"
  #   container_port   = 8080
  # }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.pj}-ecs-service-sg-${var.env}"
  description = "ECS Service Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    # security_groups = [aws_security_group.alb_sg.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.pj}-${var.env}"
  retention_in_days = 30
}

### ECS IAM Execution Role ###
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.pj}_ecs_execution_role_${var.env}"

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

resource "aws_iam_role_policy" "ecs_execution_role" {

  name = "${var.pj}-ecs-execution-policy-${var.env}"
  role = aws_iam_role.ecs_execution_role.id

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
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

### ECS IAM Execution Role ###
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.pj}_ecs_task_role_${var.env}"

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

  name = "${var.pj}-ecs-task-policy-${var.env}"
  role = aws_iam_role.ecs_task_role.id

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