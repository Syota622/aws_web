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
      image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.pj}-backend-private-repository-${var.env}:45728e2451e55a8ff2b4405e0fb6edeb449b1d44"
      readonlyRootFilesystem = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }]
      # FireLens用のログ設定
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {}
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
      image = "public.ecr.aws/aws-observability/aws-for-fluent-bit:init-latest"
      readonlyRootFilesystem = false
      essential = true
      firelensConfiguration = {
        type = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
        }
      }
      environment = [
        {
          name  = "aws_fluent_bit_init_s3_1"
          value = "${aws_s3_bucket.backend_config.arn}/${aws_s3_object.firelens_config.key}"
        }
      ]
      # FireLens用のログ設定
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.backend_ecs_logs.name
          awslogs-region = "ap-northeast-1"
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

