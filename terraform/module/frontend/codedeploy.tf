# # CodeDeployのアプリケーション
# resource "aws_codedeploy_app" "frontend" {
#   compute_platform = "ECS"
#   name             = "${var.pj}-frontend-app-${var.env}"
# }

# # CodeDeployのデプロイグループ
# resource "aws_codedeploy_deployment_group" "frontend" {
#   app_name               = aws_codedeploy_app.frontend.name
#   deployment_group_name  = "${var.pj}-frontend-dg-${var.env}"
#   service_role_arn       = aws_iam_role.codedeploy_service_role.arn
#   deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

#   ecs_service {
#     cluster_name = aws_ecs_cluster.frontend_ecs_cluster.name
#     service_name = aws_ecs_service.frontend_ecs_service.name
#   }

#   blue_green_deployment_config {
#     deployment_ready_option {
#       action_on_timeout = "CONTINUE_DEPLOYMENT"
#     }

#     terminate_blue_instances_on_deployment_success {
#       action                           = "TERMINATE"
#       termination_wait_time_in_minutes = 5
#     }
#   }

#   deployment_style {
#     deployment_option = "WITH_TRAFFIC_CONTROL"
#     deployment_type   = "BLUE_GREEN"
#   }

#   load_balancer_info {
#     target_group_pair_info {
#       prod_traffic_route {
#         listener_arns = [aws_lb_listener.frontend_https_listener.arn]
#       }

#       target_group {
#         name = aws_lb_target_group.frontend_ecs_blue_tg.name
#       }

#       target_group {
#         name = aws_lb_target_group.frontend_ecs_green_tg.name
#       }
#     }
#   }
# }

# # CodeDeploy用のIAMロール
# resource "aws_iam_role" "codedeploy_service_role" {
#   name = "${var.pj}-codedeploy-service-role-${var.env}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "codedeploy.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# # CodeDeploy用のカスタムポリシー
# resource "aws_iam_policy" "codedeploy_ecs_policy" {
#   name        = "${var.pj}-codedeploy-ecs-policy-${var.env}"
#   path        = "/"
#   description = "IAM policy for CodeDeploy ECS"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ecs:DescribeServices",
#           "ecs:CreateTaskSet",
#           "ecs:UpdateServicePrimaryTaskSet",
#           "ecs:DeleteTaskSet",
#           "elasticloadbalancing:DescribeTargetGroups",
#           "elasticloadbalancing:DescribeListeners",
#           "elasticloadbalancing:ModifyListener",
#           "elasticloadbalancing:DescribeRules",
#           "elasticloadbalancing:ModifyRule",
#           "lambda:InvokeFunction",
#           "cloudwatch:DescribeAlarms",
#           "sns:Publish",
#           "s3:GetObject",
#           "s3:GetObjectVersion"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "codedeploy_service_role_attachment" {
#   policy_arn = aws_iam_policy.codedeploy_ecs_policy.arn
#   role       = aws_iam_role.codedeploy_service_role.name
# }
