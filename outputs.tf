output "app_url" {
  description = "URL of app"
  value       = local.app_url
}

output "task_role_arn" {
  description = "The app ECS task role arn"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "vpc_id" {
  description = "ID of the VPC that was created or passed in"
  value       = var.vpc_id
}

output "alb_dns_name" {
  description = "Dns name of alb"
  value       = module.alb.this_lb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of alb"
  value       = module.alb.this_lb_zone_id
}

output "ecs_task_definition" {
  description = "Task definition for ECS service (used for external triggers)"
  value       = aws_ecs_service.app.task_definition
}

output "ecs_security_group" {
  description = "Security group assigned to ECS Service in network configuration"
  value       = module.app_sg.this_security_group_id
}
