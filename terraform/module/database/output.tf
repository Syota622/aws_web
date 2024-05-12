# Output: 
output "aurora_arn" {
  description = "Aurora Serverless ARN"
  value       = aws_rds_cluster.aurora_cluster.arn
}
