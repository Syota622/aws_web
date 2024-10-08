#################################
### Target Group（Default、バックエンド） ###
#################################

# Target Group（Default、バックエンド）
resource "aws_lb_target_group" "backend_ecs_tg" {
  name        = "${var.pj}-backend-ecs-tg-${var.env}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/graphiql"
    protocol            = "HTTP"
    matcher             = "200-299"
  }
}

##############################################
### フロントエンド Blue/Greenターゲットグループ ###
##############################################

# Blue環境用のターゲットグループ
resource "aws_lb_target_group" "frontend_ecs_blue_tg" {
  name        = "${var.pj}-frontend-blue-tg-${var.env}"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }
}

# Green環境用のターゲットグループ
resource "aws_lb_target_group" "frontend_ecs_green_tg" {
  name        = "${var.pj}-frontend-green-tg-${var.env}"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }
}
