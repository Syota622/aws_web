# AWSアカウントIDを取得
data "aws_caller_identity" "self" {}

### ECS Cluster ###
resource "aws_ecs_cluster" "backend_ecs_cluster" {
  name = "${var.pj}-backend-ecs-cluster-${var.env}"

  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }
}

### ECS Task Definition ###
resource "aws_ecs_task_definition" "backend_task_definition" {
  family                   = "${var.pj}-backend-task-definition-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.backend_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.backend_ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  # コンテナ定義
  container_definitions = jsonencode([
    {
      name  = "${var.pj}-backend-container-${var.env}"
      image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.pj}-private-repository-${var.env}:45728e2451e55a8ff2b4405e0fb6edeb449b1d44"
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }]
      # FireLens用のログ設定
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          Name       = "s3"
          region     = "ap-northeast-1"
          bucket     = aws_s3_bucket.ecs_log_s3.id
          total_file_size = "1M"
          use_put_object  = "On"
        }
      }
      secrets = [
        {
          name      = "DB_CONFIG"
          valueFrom = var.secrets_manager_arn
        },
        {
          name      = "ENV_VAR"
          valueFrom = aws_secretsmanager_secret.backend_environment.id
        },
      ]
    },
    {
      name  = "log_router"
      image = "public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"
      essential = true
      firelensConfiguration = {
        type = "fluentbit"
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend_ecs_logs.name
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "firelens"
        }
      }
      memoryReservation = 50
    }
  ])

  # lifecycle {
  #   ignore_changes = [
  #     container_definitions
  #   ]
  # }
}

### ECS Service ###
resource "aws_ecs_service" "backend_ecs_service" {
  name            = "${var.pj}-backend-ecs-service-${var.env}"
  cluster         = aws_ecs_cluster.backend_ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task_definition.arn
  launch_type     = "FARGATE"

  # ECS Exec(Fargate Connection)
  enable_execute_command = true

  desired_count = 0

  network_configuration {
    subnets          = [var.public_subnet_c_ids, var.public_subnet_d_ids]
    security_groups  = [aws_security_group.backend_ecs_sg.id]
    assign_public_ip = true
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = var.backend_ecs_tg
    container_name   = "${var.pj}-backend-container-${var.env}"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }
}

resource "aws_security_group" "backend_ecs_sg" {
  name        = "${var.pj}-backend-ecs-service-sg-${var.env}"
  description = "ECS Service Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj}-backend-ecs-service-sg-${var.env}"
  }
}

resource "aws_cloudwatch_log_group" "backend_ecs_logs" {
  name              = "/ecs/${var.pj}-backend-${var.env}"
  retention_in_days = 30
}
