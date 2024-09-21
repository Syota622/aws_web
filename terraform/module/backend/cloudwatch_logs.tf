resource "aws_cloudwatch_log_group" "backend_ecs_logs" {
  name              = "/ecs/${var.pj}-backend-${var.env}"
  retention_in_days = 30
}
