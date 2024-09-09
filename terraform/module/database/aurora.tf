### Aurora Database ###
resource "aws_rds_cluster" "aurora_cluster" {
  depends_on = [aws_secretsmanager_secret.db_credentials]

  cluster_identifier              = local.aurora_cluster_name[var.env]
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.06.0"
  database_name                   = local.credentials["DB_NAME"]
  master_username                 = local.credentials["DB_USER"]
  master_password                 = local.credentials["DB_PASSWORD"]
  backup_retention_period         = local.backup_retention_period[var.env]
  preferred_backup_window         = local.preferred_backup_window[var.env]
  preferred_maintenance_window    = local.preferred_maintenance_window[var.env]
  allow_major_version_upgrade     = false
  vpc_security_group_ids          = [aws_security_group.aurora_cluster.id]
  db_subnet_group_name            = aws_db_subnet_group.aurora_cluster.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster.name
  storage_encrypted               = true
  apply_immediately               = true
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  #削除時にスナップショットをスキップ
  skip_final_snapshot = local.skip_final_snapshot[var.env]

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2.0
  }

  tags = {
    Name = local.aurora_cluster_name[var.env]
  }

}

# Aurora Serverless
resource "aws_rds_cluster_instance" "aurora_serverless" {
  identifier          = local.aurora_serverless_name[var.env]
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.serverless"
  engine              = "aurora-mysql"
  engine_version      = "8.0.mysql_aurora.3.06.0"
  ca_cert_identifier  = "rds-ca-rsa2048-g1"
  publicly_accessible = false
  apply_immediately   = true

}

# Aurora SecurityGroup
resource "aws_security_group" "aurora_cluster" {
  name        = "${var.pj}-serverless-sg-${var.env}"
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.backend_ecs_sg_id, var.lambda_migrate_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj}-serverless-sg-${var.env}"
  }
}

# Aurora Subnet Group
resource "aws_db_subnet_group" "aurora_cluster" {
  name       = "${var.pj}_cluster_subnet_group_${var.env}"
  subnet_ids = [var.private_subnet_c_ids, var.private_subnet_d_ids]

  tags = {
    Name = "${var.pj}_cluster_subnet_group_${var.env}"
  }
}

# Aurora Parameter Group
resource "aws_rds_cluster_parameter_group" "aurora_cluster" {

  name   = "${var.pj}-serverless-parameter-group-${var.env}"
  family = "aurora-mysql8.0"
  tags = {
    Name = "${var.pj}-serverless-parameter-group-${var.env}"
  }
}
