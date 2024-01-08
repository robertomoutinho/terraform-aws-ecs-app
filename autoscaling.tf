resource "aws_appautoscaling_target" "target" {
  count              = var.enable_asg ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.asg_min_tasks
  max_capacity       = var.asg_max_tasks
  role_arn = format(
    "arn:aws:iam::%s:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService",
    data.aws_caller_identity.current.account_id,
  )
}

############################
## App Autoscaling Policy ##
############################

resource "aws_appautoscaling_policy" "auto_scaling_cpu" {

  count              = (var.enable_asg && var.enable_cpu_scaling) ? 1 : 0
  name               = "${var.environment}-${var.name}-cpu-scale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.target[0].resource_id
  service_namespace  = aws_appautoscaling_target.target[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.target[0].scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = var.asg_threshold_cpu_to_scale_up
    scale_in_cooldown  = var.asg_cooldown_to_scale_up_again
    scale_out_cooldown = var.asg_cooldown_to_scale_up_again

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.target]

}

resource "aws_appautoscaling_policy" "auto_scaling_mem" {

  count              = (var.enable_asg && var.enable_mem_scaling) ? 1 : 0
  name               = "${var.environment}-${var.name}-mem-scale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.target[0].resource_id
  service_namespace  = aws_appautoscaling_target.target[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.target[0].scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = var.asg_threshold_mem_to_scale_up
    scale_in_cooldown  = var.asg_cooldown_to_scale_up_again
    scale_out_cooldown = var.asg_cooldown_to_scale_up_again

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.target]

}
