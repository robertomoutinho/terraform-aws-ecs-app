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

# resource "aws_appautoscaling_policy" "auto_scaling" {

#   count              = var.enable_asg ? 1 : 0
#   name               = "${var.environment}-${var.name}-cpu-scale"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.target[0].resource_id
#   service_namespace  = aws_appautoscaling_target.target[0].service_namespace
#   scalable_dimension = aws_appautoscaling_target.target[0].scalable_dimension

#   target_tracking_scaling_policy_configuration {
#     target_value       = var.asg_threshold_cpu_to_scale_up
#     scale_in_cooldown  = var.asg_cooldown_to_scale_up_again
#     scale_out_cooldown = var.asg_cooldown_to_scale_down_again

#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#   }

#   depends_on = [aws_appautoscaling_target.target]

# }

###################################
## AWS Auto Scaling - Scaling Up ##
###################################

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.enable_asg ? 1 : 0
  alarm_name          = "${var.environment}-${var.name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.asg_max_cpu_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.asg_max_cpu_period
  statistic           = "Maximum"
  threshold           = var.asg_threshold_cpu_to_scale_up
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.app.name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_up_policy[0].arn]

  tags = var.tags
}

resource "aws_appautoscaling_policy" "scale_up_policy" {
  count              = var.enable_asg ? 1 : 0
  name               = "${var.environment}-${var.name}-scale-up-policy"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.asg_cooldown_to_scale_up_again
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
  depends_on = [aws_appautoscaling_target.target]
}

#####################################
## AWS Auto Scaling - Scaling Down ##
#####################################

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = var.enable_asg ? 1 : 0
  alarm_name          = "${var.environment}-${var.name}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.asg_min_cpu_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.asg_min_cpu_period
  statistic           = "Maximum"
  threshold           = var.asg_threshold_cpu_to_scale_down
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.app.name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_down_policy[0].arn]

  tags = var.tags
}

resource "aws_appautoscaling_policy" "scale_down_policy" {
  count              = var.enable_asg ? 1 : 0
  name               = "${var.environment}-${var.name}-scale-down-policy"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.asg_cooldown_to_scale_down_again
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
  depends_on = [aws_appautoscaling_target.target]
}