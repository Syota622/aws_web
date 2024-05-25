# # LoadBalancer
# resource "aws_lb" "ecs_alb" {
#   name               = "${var.pj}-ecs-alb-${var.env}"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = [var.private_subnet_c_ids, var.private_subnet_d_ids]
#   idle_timeout       = "3600"

#   enable_deletion_protection = false

#   # access_logs {
#   #   bucket  = aws_s3_bucket.alb_logs.bucket
#   #   prefix  = "log_alb"
#   #   enabled = true
#   # }
# }

# # Target Group
# resource "aws_lb_target_group" "ecs_tg" {
#   name        = "${var.pj}-ecs-tg-${var.env}"
#   port        = 8080
#   protocol    = "HTTP"
#   vpc_id      = var.vpc_id
#   target_type = "ip"

#   health_check {
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#     timeout             = 5
#     interval            = 30
#     path                = "/"
#     protocol            = "HTTP"
#     matcher             = "200-299"
#   }
# }

# # Listener
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.ecs_alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = local.acm_certificate

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ecs_tg.arn
#   }
# }

# resource "aws_security_group" "alb_sg" {
#   name        = "${var.pj}-alb-sg-${var.env}"
#   description = "ALB Security Group"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # # S3(Set IAM policy to allow ALB to write access logs to S3 buckets)
# # resource "aws_s3_bucket" "alb_logs" {
# #   bucket = "${var.pj}-alb-logs-${var.env}"
# # }

# # # public access enabled
# # resource "aws_s3_bucket_public_access_block" "alb_logs" {
# #   bucket                  = aws_s3_bucket.alb_logs.id
# #   block_public_acls       = true
# #   block_public_policy     = true
# #   ignore_public_acls      = true
# #   restrict_public_buckets = true
# # }

# # resource "aws_s3_bucket_versioning" "alb_logs" {
# #   bucket = aws_s3_bucket.alb_logs.id
# #   versioning_configuration {
# #     status = "Enabled"
# #   }
# # }

# # resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
# #   bucket = aws_s3_bucket.alb_logs.id

# #   rule {
# #     id     = "log_expiration"
# #     status = "Enabled"

# #     expiration {
# #       days = 90
# #     }
# #   }
# # }

# # # IAM policy for ALB to write logs to the S3 bucket
# # data "aws_iam_policy_document" "alb_logs" {
# #   statement {
# #     effect = "Allow"
# #     principals {
# #       type        = "AWS"
# #       identifiers = ["arn:aws:iam::582318560864:root"] # elb account id(https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#attach-bucket-policy)
# #     }
# #     actions   = ["s3:PutObject"]
# #     resources = ["arn:aws:s3:::${aws_s3_bucket.alb_logs.bucket}/*"]
# #   }
# # }

# # # Apply the IAM policy to the S3 bucket
# # resource "aws_s3_bucket_policy" "alb_logs" {
# #   bucket = aws_s3_bucket.alb_logs.id
# #   policy = data.aws_iam_policy_document.alb_logs.json
# # }
