resource "aws_secretsmanager_secret" "frontend_environment" {
  name = "${var.pj}/frontend_ecs/environment/${var.env}"
}