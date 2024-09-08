resource "aws_secretsmanager_secret" "backend_environment" {
  name = "${var.pj}/backend/ecs/environment/${var.env}"
}