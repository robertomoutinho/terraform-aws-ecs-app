resource "aws_appautoscaling_target" "target" {
  count              = var.enable_asg ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.asg_min_tasks
  max_capacity       = var.asg_max_tasks
}

############################
## App Autoscaling Policy ##
############################

resource "aws_appautoscaling_policy" "auto_scaling" {

  count              = var.enable_asg ? 1 : 0
  name               = "${var.environment}-${var.name}-scale-up"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "TargetTrackingScaling"

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