# AWSアカウントIDを取得
data "aws_caller_identity" "self" {}

### ECS Cluster ###
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.pj}-ecs-cluster-${var.env}"

  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }
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
    name = "${var.pj}-container-${var.env}",
    # ECRのイメージを指定
    image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.pj}-private-repository-${var.env}:latest",
    portMappings = [{
      containerPort = 8080,
      hostPort      = 8080
    }]
    # ログの設定
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "ecs"
      }
    },
    # 環境変数の設定（SecretsManager）
    secrets = [
      {
        name      = "DB_USER",
        valueFrom = var.secrets_manager_arn
      },
      {
        name      = "DB_PASSWORD",
        valueFrom = var.secrets_manager_arn
      },
      {
        name      = "DB_NAME",
        valueFrom = var.secrets_manager_arn
      },
      {
        name      = "DB_PORT",
        valueFrom = var.secrets_manager_arn
      },
      {
        name      = "DB_HOST",
        valueFrom = var.secrets_manager_arn
      }
    ]
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

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "${var.pj}-container-${var.env}"
    container_port   = 8080
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.pj}-ecs-service-sg-${var.env}"
  description = "ECS Service Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj}-ecs-service-sg-${var.env}"
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.pj}-${var.env}"
  retention_in_days = 30
}
