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
    scale_out_cooldown = var.asg_cooldown_to_scale_down_again

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
    scale_out_cooldown = var.asg_cooldown_to_scale_down_again

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.target]

}

resource "aws_appautoscaling_policy" "auto_scaling_request" {

  count              = (var.enable_asg && var.enable_alb && var.enable_request_scaling) ? 1 : 0
  name               = "${var.environment}-${var.name}-request-scale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.target[0].resource_id
  service_namespace  = aws_appautoscaling_target.target[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.target[0].scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = var.asg_threshold_request_to_scale_up
    scale_in_cooldown  = var.asg_cooldown_to_scale_up_again
    scale_out_cooldown = var.asg_cooldown_to_scale_down_again

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${module.alb.0.this_lb_arn_suffix}/${module.alb.0.target_group_arn_suffixes[0]}"
    }
  }

  depends_on = [aws_appautoscaling_target.target]

}

#######################
## Custom Cloudwatch ##
#######################

resource "aws_appautoscaling_policy" "this" {

  for_each = { for k, v in var.asg_custom_policies : k => v if var.enable_custom_scaling }

  name               = "${var.environment}-${var.name}-custom-scale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.target[0].resource_id
  service_namespace  = aws_appautoscaling_target.target[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.target[0].scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = try(each.value.target_tracking_scaling_policy_configuration.value.target_value, 75)
    scale_in_cooldown  = try(each.value.target_tracking_scaling_policy_configuration.value.scale_in_cooldown, 300)
    scale_out_cooldown = try(each.value.target_tracking_scaling_policy_configuration.value.scale_out_cooldown, 60)
    dynamic "customized_metric_specification" {
      for_each = try([each.value.target_tracking_scaling_policy_configuration.value.customized_metric_specification], [])
      content {
        dynamic "metrics" {
          for_each = try([customized_metric_specification.value.metrics], [])
          content {
            id          = metrics.value.id
            label       = metrics.value.label
            return_data = metrics.value.return_data
            dynamic "metric_stat" {
              for_each = try([metrics.value.metric_stat], [])
              content {
                stat = metric_stat.value.stat
                dynamic "metric" {
                  for_each = try([metric_stat.value.metric], [])
                  content {
                    namespace   = metric.value.namespace
                    metric_name = metric.value.metric_name
                    dynamic "dimensions" {
                      for_each = try([metric.value.dimensions], [])
                      content {
                        name  = dimensions.value.name
                        value = dimensions.value.value
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [aws_appautoscaling_target.target]

}