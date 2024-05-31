# Output: 
output "aurora_arn" {
  description = "Aurora Serverless ARN"
  value       = aws_rds_cluster.aurora_cluster.arn
}

output "secrets_manager_arn" {
  description = "SecretsManager ARN"
  value       = aws_secretsmanager_secret.db_credentials.id
}
