resource "aws_secretsmanager_secret" "environment" {
  name = "${var.pj}/ecs/environment/${var.env}"
}