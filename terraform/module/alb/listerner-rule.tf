### リスナールール ###

# フロントエンド Blue/Green リスナールール
resource "aws_lb_listener_rule" "blue_green" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_ecs_blue_tg.arn
  }

  condition {
    host_header {
      values = ["mokokero.com"]
    }
  }
}

# バックエンド api.mokokero.com リスナールール
resource "aws_lb_listener_rule" "api_mokokero_com_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_ecs_tg.arn
  }

  condition {
    host_header {
      values = ["api.mokokero.com"]
    }
  }
}
