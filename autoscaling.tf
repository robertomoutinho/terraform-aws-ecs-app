resource "aws_appautoscaling_target" "target" {
  count              = var.enable_asg ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.asg_min_tasks
  max_capacity       = var.asg_max_tasks
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "up" {

  count              = var.enable_asg ? 1 : 0
  name               = "${var.environment}-${var.name}-scale-up"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.app.name}"
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

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down" {

  count              = var.enable_asg ? 1 : 0
  name               = "${var.environment}-${var.name}-scale-down"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.app.name}"
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

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {

  count               = var.enable_asg ? 1 : 0
  alarm_name          = "${var.environment}-${var.name}-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.asg_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.asg_period
  statistic           = "Average"
  threshold           = var.asg_threshold_cpu_to_scale_up

  dimensions = {
    ClusterName = var.ecs_cluster_id
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [aws_appautoscaling_policy.up[0].arn]

}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {

  count               = var.enable_asg ? 1 : 0
  alarm_name          = "${var.environment}-${var.name}-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.asg_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.asg_period
  statistic           = "Average"
  threshold           = var.asg_threshold_cpu_to_scale_down

  dimensions = {
    ClusterName = var.ecs_cluster_id
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [aws_appautoscaling_policy.down[0].arn]

}