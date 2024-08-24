#####
# 開発者利用時間：平日09:30〜21:30
####

### IAM Role for EventBridge Scheduler ###
resource "aws_iam_role" "aurora_scheduler" {
  name = "${var.pj}-aurora-scheduler-role-${var.env}"

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

resource "aws_iam_role_policy" "aurora_scheduler" {
  name = "${var.pj}-aurora-scheduler-policy-${var.env}"
  role = aws_iam_role.aurora_scheduler.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:StartDBCluster",
          "rds:StopDBCluster"
        ],
        Resource = [
          aws_rds_cluster.aurora_cluster.arn
        ]
      }
    ]
  })
}

# ### EventBridge Scheduler ###

# ## Aurora Serverless ##
# # Aurora Serverless Instance Start Scheduler
# resource "aws_scheduler_schedule" "aurora8_start" {
#   name        = "${var.pj}-aurora-start-scheduler-${var.env}"
#   description = "Start Aurora Instance on Weekdays at 08:45 JST"

#   schedule_expression = "cron(45 23 ? * SUN-THU *)"

#   flexible_time_window {
#     mode = "OFF"
#   }

#   target {
#     arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster"
#     role_arn = aws_iam_role.aurora_scheduler.arn

#     input = jsonencode({
#       "DbClusterIdentifier" : aws_rds_cluster.aurora_cluster.arn
#     })
#   }
# }

# Aurora8 Instance Stop Scheduler
resource "aws_scheduler_schedule" "aurora8_aurora_stop" {
  name        = "${var.pj}-aurora-stop-scheduler-${var.env}"
  description = "Stop Aurora Instance on Weekdays at 21:55 JST"

  schedule_expression = "cron(55 12 ? * MON-FRI *)"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster"
    role_arn = aws_iam_role.aurora_scheduler.arn

    input = jsonencode({
      "DbClusterIdentifier" : aws_rds_cluster.aurora_cluster.arn
    })
  }
}
