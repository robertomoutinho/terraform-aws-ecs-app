locals {
  ecs_service_name                = var.name
  ecs_task_definition_family_name = "${var.environment}-${var.name}"
  container_name                  = var.name
  container_image                 = data.external.current_image.result["image_tag"] == "not_found" ? "nginx:latest" : "${var.app_ecr_image_repo}:${data.external.current_image.result["image_tag"]}"
  latest_task_definition          = "${aws_ecs_task_definition.app.family}:${max(aws_ecs_task_definition.app.revision, data.external.current_image.result["task_definition_revision"])}"
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
  name                               = local.ecs_service_name
  cluster                            = data.aws_ecs_cluster.cluster.arn
  task_definition                    = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/${local.latest_task_definition}"
  desired_count                      = var.ecs_service_desired_count
  launch_type                        = "FARGATE"
  propagate_tags                     = "SERVICE"
  enable_ecs_managed_tags            = true
  deployment_maximum_percent         = var.ecs_service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [module.app_sg.this_security_group_id]
    assign_public_ip = var.ecs_service_assign_public_ip
  }

  dynamic "service_registries" {
    for_each = aws_service_discovery_service.sds
    content {
      container_name = local.container_name
      registry_arn   = service_registries.value.arn
    }
  }

  dynamic "load_balancer" {
    for_each = module.alb
    content {
      container_name   = local.container_name
      container_port   = var.app_port_mapping.0.containerPort
      target_group_arn = load_balancer.value.target_group_arns[0]
    }
  }

  tags = local.local_tags
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.58.1"

  container_name  = local.container_name
  container_image = var.app_docker_image == "" ? local.container_image : var.app_docker_image

  container_cpu                = var.ecs_task_cpu
  container_memory             = var.ecs_task_memory
  container_memory_reservation = var.container_memory_reservation

  port_mappings = var.app_port_mapping

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = data.aws_region.current.name
      awslogs-group         = aws_cloudwatch_log_group.app.name
      awslogs-stream-prefix = "ecs"
    }
    secretOptions = []
  }

  environment = var.custom_environment_variables
  secrets     = var.custom_environment_secrets

}

resource "aws_ecs_task_definition" "app" {

  family                   = local.ecs_task_definition_family_name
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  container_definitions    = module.container_definition.json_map_encoded_list

  tags = local.local_tags
}