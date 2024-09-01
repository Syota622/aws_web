# Output: 
### SecurityGroup
output "lambda_migrate_sg_id" {
  description = "SecurityGroup id"
  value       = aws_security_group.lambda_migrate_sg.id
}
