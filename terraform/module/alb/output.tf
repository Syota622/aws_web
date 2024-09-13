# Output: 
## ALB
output "alb_dns" {
  description = "ALB DNS"
  value       = aws_lb.ecs_alb.dns_name
}

output "alb_zone_id" {
  description = "ALB Id"
  value       = aws_lb.ecs_alb.zone_id
}

output "alb_sg_id" {
  description = "ALB Security Group Id"
  value       = aws_security_group.alb_sg.id
}

output "backend_ecs_tg" {
  description = "Backend Target Group ARN"
  value       = aws_lb_target_group.backend_ecs_tg.arn
}
