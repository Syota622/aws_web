# LoadBalancer
resource "aws_lb" "backend_ecs_alb" {
  name               = "${var.pj}-backend-ecs-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_alb_sg.id]
  subnets            = [var.public_subnet_c_ids, var.public_subnet_d_ids]
  idle_timeout       = "3600"

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.alb_logs.bucket
  #   prefix  = "log_alb"
  #   enabled = true
  # }
}

# Target Group
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

# Listener: https
resource "aws_lb_listener" "backend_https_listener" {
  load_balancer_arn = aws_lb.backend_ecs_alb.arn
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

# Listener: httpからhttpsへのリダイレクト
resource "aws_lb_listener" "backend_http_listener" {
  load_balancer_arn = aws_lb.backend_ecs_alb.arn
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

resource "aws_security_group" "backend_alb_sg" {
  name        = "${var.pj}-backend-alb-sg-${var.env}"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj}-backend-alb-sg-${var.env}"
  }
}
