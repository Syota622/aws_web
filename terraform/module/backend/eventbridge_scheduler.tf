### IAM Role for EventBridge Scheduler ###
resource "aws_iam_role" "backend_fargate_scheduler" {
  count = var.env == "dev" || var.env == "prod" || var.env == "stg" ? 1 : 0

  name = "${var.pj}-backend-fargate-scheduler-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com",
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "backend_fargate_scheduler" {
  count = var.env == "dev" || var.env == "prod" || var.env == "stg" ? 1 : 0

  name = "${var.pj}-backend-fargate-scheduler-policy-${var.env}"
  role = aws_iam_role.backend_fargate_scheduler[count.index].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:UpdateService"
        ],
        Resource = [
          aws_ecs_service.backend_ecs_service.id
        ]
      }
    ]
  })
}

### EventBridge Scheduler ###

# ## Fargate ##
# # Fargate Start Scheduler
# resource "aws_scheduler_schedule" "fargate_start" {
#   count = var.env == "dev" || var.env == "prod" || var.env == "stg" ? 1 : 0

#   name        = "${var.pj}-fargate-start-scheduler-${var.env}"
#   description = "Start fargate on Weekdays at 08:45 JST"

#   schedule_expression = "cron(45 23 ? * SUN-THU *)"

#   flexible_time_window {
#     mode = "OFF"
#   }

#   target {
#     arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
#     role_arn = aws_iam_role.fargate_scheduler[count.index].arn

#     input = jsonencode({
#       "Cluster" : aws_ecs_cluster.ecs_cluster.name,
#       "Service" : aws_ecs_service.ecs_service.name
#       "DesiredCount" : 1
#     })
#   }
# }

# Fargate Stop Scheduler
resource "aws_scheduler_schedule" "backend_fargate_fargate_stop" {
  count       = var.env == "dev" || var.env == "prod" || var.env == "stg" ? 1 : 0
  description = "Stop fargate on Weekdays at 23:55 JST"

  name = "${var.pj}-backend-fargate-stop-scheduler-${var.env}"

  schedule_expression = "cron(45 23 ? * SUN-THU *)"
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.backend_fargate_scheduler[count.index].arn

    input = jsonencode({
      "Cluster" : aws_ecs_cluster.backend_ecs_cluster.name,
      "Service" : aws_ecs_service.backend_ecs_service.name
      "DesiredCount" : 0
    })
  }
}
