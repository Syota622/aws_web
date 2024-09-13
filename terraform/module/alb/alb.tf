# LoadBalancer
resource "aws_lb" "ecs_alb" {
  name               = "${var.pj}-ecs-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.public_subnet_c_ids, var.public_subnet_d_ids]
  idle_timeout       = "3600"

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.alb_logs.bucket
  #   prefix  = "log_alb"
  #   enabled = true
  # }
}
