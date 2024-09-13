resource "aws_secretsmanager_secret" "frontend_environment" {
  name = "${var.pj}/frontend/ecs/environment/${var.env}"
}