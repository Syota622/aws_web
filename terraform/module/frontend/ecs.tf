# AWSアカウントIDを取得
data "aws_caller_identity" "self" {}

### ECS Cluster ###
resource "aws_ecs_cluster" "frontend_ecs_cluster" {
  name = "${var.pj}-frontend-ecs-cluster-${var.env}"

  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }
}

### ECS Task Definition ###
resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                   = "${var.pj}-frontend-task-definition-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.frontend_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.frontend_ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  # コンテナ定義
  container_definitions = jsonencode([{
    name = "${var.pj}-frontend-container-${var.env}",

    # ECRのイメージを指定: GitHub ActionsでビルドしたイメージのURIを指定
    image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.pj}-frontend-private-repository-${var.env}:latest", 
    portMappings = [{
      containerPort = 3000,
      hostPort      = 3000
    }]
    # ログの設定
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.frontend_ecs_logs.name
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "ecs"
      }
    },
    # # 環境変数の設定（SecretsManager）
    # # ENVIRONMENT: マネジメントコンソールから作成したシークレット
    # secrets = [
    #   {
    #     name      = "ENVIRONMENT",
    #     valueFrom = aws_secretsmanager_secret.environment.id
    #   },
    # ]
  }])

  # lifecycle {
  #   ignore_changes = [
  #     container_definitions
  #   ]
  # }
}

### ECS Service ###
resource "aws_ecs_service" "frontend_ecs_service" {
  name            = "${var.pj}-frontend-ecs-service-${var.env}"
  cluster         = aws_ecs_cluster.frontend_ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task_definition.arn
  launch_type     = "FARGATE"

  # ECS Exec(Fargate Connection)
  enable_execute_command = true

  desired_count = 1 # Blue/Greenデプロイのため、少なくとも1つのタスクが必要

  network_configuration {
    subnets          = [var.public_subnet_c_ids, var.public_subnet_d_ids]
    security_groups  = [aws_security_group.frontend_ecs_sg.id]
    assign_public_ip = true
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_ecs_blue_tg.arn # Blue環境用のターゲットグループ
    container_name   = "${var.pj}-frontend-container-${var.env}"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer
    ]
  }
}

resource "aws_security_group" "frontend_ecs_sg" {
  name        = "${var.pj}-frontend-ecs-service-sg-${var.env}"
  description = "ECS Service Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_alb_sg.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj}-frontend-ecs-service-sg-${var.env}"
  }
}

resource "aws_cloudwatch_log_group" "frontend_ecs_logs" {
  name              = "/ecs/${var.pj}-frontend-${var.env}"
  retention_in_days = 30
}
