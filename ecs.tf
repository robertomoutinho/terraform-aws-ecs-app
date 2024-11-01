locals {
  ecs_service_name                = var.name
  ecs_task_definition_family_name = "${var.environment}-${var.name}"
  container_name                  = var.name
  container_image                 = data.external.current_image.result["image_tag"] == "not_found" ? "nginx:latest" : "${var.app_ecr_image_repo}:${data.external.current_image.result["image_tag"]}"
  # container_image_version         = data.external.current_image.result["image_tag"] == "not_found" ? "latest" : element(split(separator,data.external.current_image.result["image_tag"]),1)
  latest_task_definition = "${aws_ecs_task_definition.app.family}:${max(aws_ecs_task_definition.app.revision, data.external.current_image.result["task_definition_revision"])}"
  datadog_docker_labels = {
    "com.datadoghq.tags.env"     = var.environment,
    "com.datadoghq.tags.service" = var.datadog_service_name == "" ? var.name : var.datadog_service_name
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_cluster_name
}

data "external" "current_image" {
  program = ["bash", "${path.module}/scripts/app_image_version.sh"]
  query = {
    service    = local.ecs_service_name
    cluster    = data.aws_ecs_cluster.cluster.arn
    path_root  = jsonencode(path.root)
    account_id = data.aws_caller_identity.current.account_id
    region     = data.aws_region.current.name
    role_arn   = var.iam_role_for_external_datasource
  }
}

#########
## ECS ##
#########

resource "aws_ecs_service" "app" {
  name            = local.ecs_service_name
  cluster         = data.aws_ecs_cluster.cluster.arn
  task_definition = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/${local.latest_task_definition}"
  desired_count   = var.ecs_service_desired_count
  # launch_type                        = var.ecs_launch_type
  propagate_tags                     = "SERVICE"
  enable_ecs_managed_tags            = true
  enable_execute_command             = var.ecs_enable_execute_command
  deployment_maximum_percent         = var.ecs_service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = var.ecs_service_assign_public_ip
  }

  capacity_provider_strategy {
    capacity_provider = var.ecs_capacity_provider
    weight            = 1
  }

  dynamic "service_registries" {
    for_each = aws_service_discovery_service.sds
    content {
      container_name = local.container_name
      registry_arn   = service_registries.value.arn
    }
  }

  # application load balancer
  dynamic "load_balancer" {
    for_each = module.alb
    content {
      container_name   = local.container_name
      container_port   = var.app_port_mapping.0.containerPort
      target_group_arn = load_balancer.value.target_group_arns[0]
    }
  }

  dynamic "load_balancer" {
    for_each = var.alb_extra_target_groups
    content {
      container_name   = local.container_name
      container_port   = var.app_port_mapping.0.containerPort
      target_group_arn = load_balancer.value
    }
  }

  # network load balancer
  dynamic "load_balancer" {
    for_each = aws_lb_target_group.nlb_tg
    content {
      container_name   = local.container_name
      container_port   = var.app_port_mapping.0.containerPort
      target_group_arn = aws_lb_target_group.nlb_tg.0.arn
    }
  }

  tags = local.local_tags

  lifecycle {
    ignore_changes = [desired_count]
  }

}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.58.1"

  container_name  = local.container_name
  container_image = var.app_docker_image == "" ? local.container_image : var.app_docker_image
  command         = var.app_container_command
  ulimits         = var.ecs_ulimits
  pseudo_terminal = var.ecs_pseudo_terminal
  stop_timeout    = var.ecs_stop_timeout

  container_cpu                = var.ecs_task_cpu
  container_memory             = var.ecs_task_memory
  container_memory_reservation = var.container_memory_reservation
  linux_parameters             = var.ecs_linux_parameters

  port_mappings = var.app_port_mapping
  mount_points  = var.ecs_mount_points

  repository_credentials = (var.repository_credentials_name != null
    ? { credentialsParameter = data.aws_secretsmanager_secret.creds[0].arn }
    : null
  )

  log_configuration = (var.enable_datadog_log_forwarder ? {
    logDriver = "awsfirelens"
    options = {
      "Name"       = "datadog",
      "dd_service" = var.datadog_service_name == "" ? var.name : var.datadog_service_name,
      "dd_source"  = "firelens",
      "dd_tags"    = "env:${var.environment}",
      "TLS"        = "on",
      "provider"   = "ecs"
    }
    secretOptions = [
      {
        name      = "apiKey",
        valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/shared/datadog/api_key"
      }
    ]
  } : {
    logDriver = "awslogs"
    options = {
      awslogs-region        = data.aws_region.current.name
      awslogs-group         = aws_cloudwatch_log_group.app.name
      awslogs-stream-prefix = "ecs"
    }
    secretOptions = []
  })

  container_depends_on = (var.enable_datadog_sidecar ? [
    {
      containerName = "datadog-agent"
      condition     = "START"
    }
  ] : null)

  docker_labels = var.enable_datadog_sidecar ? merge(local.datadog_docker_labels, var.docker_labels) : var.docker_labels

  environment = var.enable_datadog_sidecar ? flatten(concat(var.custom_environment_variables,
    [
      {
        name  = "DD_VERSION"
        value = data.external.current_image.result["image_tag"]
      }
    ]
  )) : var.custom_environment_variables
  secrets = var.custom_environment_secrets
}

resource "aws_ecs_task_definition" "app" {
  #checkov:skip=CKV_AWS_97:
  family                   = local.ecs_task_definition_family_name
  execution_role_arn       = var.create_default_role ? aws_iam_role.ecs_task_execution[0].arn : var.external_iam_role
  task_role_arn            = var.create_default_role ? aws_iam_role.ecs_task_execution[0].arn : var.external_iam_role
  network_mode             = "awsvpc"
  requires_compatibilities = var.ecs_requires_compatibilities
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory

  ephemeral_storage {
    size_in_gib = var.ecs_ephemeral_storage_size
  }

  container_definitions = (
    var.enable_datadog_sidecar && var.enable_datadog_log_forwarder
    ? jsonencode([module.container_definition.json_map_object, module.datadog_sidecar.json_map_object, module.datadog_firelens.json_map_object])
    : var.enable_datadog_sidecar
    ? jsonencode([module.container_definition.json_map_object, module.datadog_sidecar.json_map_object])
    : module.container_definition.json_map_encoded_list
  )

  dynamic "volume" {
    for_each = { for k, v in var.ecs_efs_volumes : k => v }
    content {
      name = volume.value["name"]
      efs_volume_configuration {
        file_system_id          = volume.value["efs_volume_configuration"]["file_system_id"]
        root_directory          = volume.value["efs_volume_configuration"]["root_directory"]
        transit_encryption      = "ENABLED"
        transit_encryption_port = lookup(volume.value["efs_volume_configuration"], "transit_encryption_port", 2999)
        authorization_config {
          access_point_id = volume.value["authorization_config"]["access_point_id"]
          iam             = lookup(volume.value["authorization_config"], "iam", "DISABLED")
        }
      }
    }
  }

  pid_mode = var.datadog_process_collection_enabled ? "task" : null

  tags = local.local_tags
}
