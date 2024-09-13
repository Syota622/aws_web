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

output "frontend_ecs_blue_tg" {
  description = "Blue Frontend Target Group ARN"
  value       = aws_lb_target_group.frontend_ecs_blue_tg.arn
}

output "frontend_ecs_green_tg" {
  description = "Green Frontend Target Group ARN"
  value       = aws_lb_target_group.frontend_ecs_green_tg.arn
}

output "https_listener" {
  description = "Frontend HTTPS Listener ARN"
  value       = aws_lb_listener.https_listener.arn
}

output "frontend_4430_listener" {
  description = "Frontend 4430 Listener ARN"
  value       = aws_lb_listener.frontend_4430_listener.arn
}
