module "datadog_sidecar" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.58.1"

  container_name  = "datadog-agent"
  container_image = var.datadog_agent_container_image
  essential       = var.datadog_agent_container_essential

  port_mappings = [
    {
      "protocol" : "tcp",
      "containerPort" : 8125,
      "hostPort" : 8125
    },
    {
      "protocol" : "tcp",
      "containerPort" : 8126,
      "hostPort" : 8126
    }
  ]

  environment = [
    {
      name  = "ECS_FARGATE"
      value = true
    },
    {
      name  = "DD_APM_ENABLED",
      value = true
    },
    {
      name  = "DD_APM_NON_LOCAL_TRAFFIC",
      value = true
    },
    {
      name  = "DD_APM_RECEIVER_PORT",
      value = 8126
    },
    {
      name  = "DD_DOGSTATSD_NON_LOCAL_TRAFFIC",
      value = true
    },
    {
      name  = "DD_DOGSTATSD_PORT",
      value = 8125
    },
    {
      name  = "DD_CONTAINER_EXCLUDE",
      value = "name:datadog-agent name:log_router"
    },
    {
      name  = "DD_TAGS"
      value = replace(var.datadog_tags, ",", " ")
    },
    {
      name  = "DD_PROCESS_AGENT_PROCESS_COLLECTION_ENABLED"
      value = tostring(var.datadog_process_collection_enabled)
    }
  ]

  secrets = [
    {
      name      = "DD_API_KEY"
      valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/shared/datadog/api_key"
    },
  ]

}
