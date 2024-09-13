# Listener: httpからhttpsへのリダイレクト
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener: https
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate

  # default_action {
  #   type  = "authenticate-cognito"
  #   order = 2
  #   authenticate_cognito {
  #     user_pool_arn       = var.basic_user_pool_arn
  #     user_pool_client_id = var.basic_user_pool_client_back_id
  #     user_pool_domain    = var.basic_user_pool_domain
  #   }
  # }

  default_action {
    type             = "forward"
    order            = 1
    target_group_arn = aws_lb_target_group.backend_ecs_tg.arn
  }

}
