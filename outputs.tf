output "task_role_arn" {
  description = "The app ECS task role arn"
  value       = var.create_default_role ? aws_iam_role.ecs_task_execution[0].arn : var.external_iam_role
}

output "vpc_id" {
  description = "ID of the VPC that was created or passed in"
  value       = var.vpc_id
}

output "alb_id" {
  description = "The ID and ARN of the load balancer we created"
  value       = try(module.alb.0.this_lb_id, null)
}

output "alb_dns_name" {
  description = "Dns name of alb"
  value       = try(module.alb.0.this_lb_dns_name, null)
}

output "alb_zone_id" {
  description = "Zone ID of alb"
  value       = try(module.alb.0.this_lb_zone_id, null)
}

output "alb_https_tcp_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = try(module.alb.0.https_listener_arns, null)
}

output "alb_target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = try(module.alb.0.target_group_arns, null)
}

output "ecs_task_definition" {
  description = "Task definition for ECS service (used for external triggers)"
  value       = aws_ecs_service.app.task_definition
}

output "ecs_security_group" {
  description = "Security group assigned to ECS Service in network configuration"
  value       = aws_security_group.app.id
}

output "cloudwatch_group_name" {
  description = "The AWS cloudwatch group name"
  value       = aws_cloudwatch_log_group.app.name
}