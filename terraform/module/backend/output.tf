# Output: 
## ECS
output "backend_ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.backend_ecs_cluster.name
}

output "backend_ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.backend_ecs_cluster.id
}

output "backend_ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.backend_ecs_service.name
}

output "backend_ecs_service_arn" {
  description = "ECS Service ARN"
  value       = aws_ecs_service.backend_ecs_service.id
}

output "backend_ecs_sg_id" {
  description = "SecurityGroup id"
  value       = aws_security_group.backend_ecs_sg.id
}
