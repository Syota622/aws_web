# Output: 
## ECS
output "frontend_ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.frontend_ecs_cluster.name
}

output "frontend_ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.frontend_ecs_cluster.id
}

output "frontend_ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.frontend_ecs_service.name
}

output "frontend_ecs_service_arn" {
  description = "ECS Service ARN"
  value       = aws_ecs_service.frontend_ecs_service.id
}

output "frontend_ecs_sg_id" {
  description = "SecurityGroup id"
  value       = aws_security_group.frontend_ecs_sg.id
}

## ALB
output "frontend_alb_dns" {
  description = "ALB DNS"
  value       = aws_lb.frontend_ecs_alb.dns_name
}

output "frontend_alb_zone_id" {
  description = "ALB Id"
  value       = aws_lb.frontend_ecs_alb.zone_id
}
