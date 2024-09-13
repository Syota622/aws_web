# # ALBリスナールールの更新
# resource "aws_lb_listener_rule" "blue_green" {
#   listener_arn = aws_lb_listener.https_listener.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ecs_blue_tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/*"]
#     }
#   }
# }