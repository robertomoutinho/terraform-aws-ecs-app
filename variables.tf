variable "environment" {
  type        = string
  description = "The name of the environment"
}

variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
}

variable "name" {
  description = "Name to use on all resources created (VPC, ALB, etc)"
  type        = string
  default     = "app"
}

variable "secret_path" {
  description = "path to append to IAM secrets access policy"
  type        = string
  default     = ""
}

variable "repository_credentials_name" {
  description = "The SecretsManager Secret Name of the repository credentials to use"
  type        = string
  default     = null
}

variable "app_fqdn" {
  description = "FQDN of app to use. Set this only to override Route53 and ALB's DNS name."
  type        = string
  default     = null
}

variable "iam_role_for_external_datasource" {
  description = "This Role is used to get the current app version deploy to ECS"
  type        = string
}

# VPC
variable "vpc_id" {
  description = "ID of an existing VPC where resources will be created"
  type        = string
  default     = ""
}

variable "public_subnet_ids" {
  description = "A list of IDs of existing public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "A list of IDs of existing private subnets inside the VPC"
  type        = list(string)
  default     = []
}

# NLB
variable "enable_nlb" {
  description = "IF an network load balancer should be created"
  type        = bool
  default     = false
}

# ALB
variable "enable_alb" {
  description = "IF an application load balancer should be created"
  type        = bool
  default     = true
}

variable "alb_internal" {
  description = "Whether the load balancer is internal or external"
  type        = bool
  default     = false
}

variable "alb_ingress_cidr_blocks" {
  description = "Comma separated string of IPv4 CIDR ranges to use on all ingress rules of the ALB."
  type        = string
  default     = "0.0.0.0/0"
}

variable "alb_log_bucket_name" {
  description = "S3 bucket (externally created) for storing load balancer access logs. Required if alb_logging_enabled is true."
  type        = string
  default     = ""
}

variable "alb_log_location_prefix" {
  description = "S3 prefix within the log_bucket_name under which logs are stored."
  type        = string
  default     = ""
}

variable "alb_logging_enabled" {
  description = "Controls if the ALB will log requests to S3."
  type        = bool
  default     = false
}

variable "alb_extra_acm_cert_arn" {
  description = "The ARN of the ACM SSL certificate for the extra cert"
  type        = list(string)
  default     = []
}

variable "alb_extra_security_group_ids" {
  description = "List of one or more security groups to be added to the load balancer"
  type        = list(string)
  default     = []
}

variable "alb_extra_target_groups" {
  description = "List of one or more target groups to be added to the load balancer"
  type        = list(string)
  default     = []
}

variable "health_check_interval" {
  description = "Healthcheck interval"
  type        = number
  default     = 15
}

variable "health_check_path" {
  description = "Healthcheck interval"
  type        = string
  default     = "/"
}

variable "health_check_healthy_threshold" {
  description = "Healthcheck interval"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Healthcheck interval"
  type        = number
  default     = 4
}

variable "health_check_timeout" {
  description = "Healthcheck interval"
  type        = number
  default     = 5
}

variable "health_check_http_code_matcher" {
  description = "Healthcheck interval"
  type        = string
  default     = "200-399"
}

# AutoScaling Group
variable "enable_asg" {
  description = "If autoscaling should be enabled"
  type        = bool
  default     = false
}

variable "enable_cpu_scaling" {
  description = "If autoscaling should be enabled based on CPU"
  type        = bool
  default     = true
}

variable "enable_mem_scaling" {
  description = "If autoscaling should be enabled based on Memory"
  type        = bool
  default     = false
}

variable "enable_request_scaling" {
  description = "If autoscaling should be enabled based on qtd of request for ALB"
  type        = bool
  default     = false
}

variable "asg_max_tasks" {
  description = "The amount of maximum tasks"
  type        = number
  default     = 3
}

variable "asg_min_tasks" {
  description = "The amount of minimum tasks"
  type        = number
  default     = 1
}

variable "asg_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = number
  default     = 5
}

variable "asg_period" {
  description = "The period in seconds over which the specified statistic is applied"
  type        = number
  default     = 60
}

variable "asg_threshold_cpu_to_scale_up" {
  description = "The value against which the specified statistic is compared."
  type        = number
  default     = 60
}

variable "asg_threshold_mem_to_scale_up" {
  description = "The value against which the specified statistic is compared."
  type        = number
  default     = 60
}

variable "asg_threshold_request_to_scale_up" {
  description = "The value against which the specified statistic is compared."
  type        = number
  default     = 100
}

variable "asg_cooldown_to_scale_up_again" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling up activity can start."
  type        = number
  default     = 60
}

variable "asg_cooldown_to_scale_down_again" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling down activity can start."
  type        = number
  default     = 300
}

# Custom ASG

variable "enable_custom_scaling" {
  description = "If autoscaling should be enabled based on a custom metric"
  type        = bool
  default     = false
}

variable "asg_custom_policies" {
  description = "Map of autoscaling policies to create for the service"
  type        = any
  default = {
    cpu = {
      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
      }
    }
    memory = {
      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
      }
    }
  }
}

# ACM
variable "certificate_arn" {
  description = "ARN of certificate issued by AWS ACM."
  type        = string
  default     = ""
}

# Route53
variable "route53_zone_name" {
  description = "Route53 zone name to create ACM certificate in and main A-record, without trailing dot"
  type        = string
  default     = ""
}

variable "route53_record_name" {
  description = "Name of Route53 record to create ACM certificate in and main A-record. If null is specified, var.name is used instead. Provide empty string to point root domain name to ALB."
  type        = string
  default     = null
}

variable "create_route53_record" {
  description = "Whether to create Route53 record for app"
  type        = bool
  default     = true
}

# Cloudwatch
variable "cloudwatch_log_retention_in_days" {
  description = "Retention period of app CloudWatch logs"
  type        = number
  default     = 7
}

# IAM
variable "create_default_role" {
  description = "Default role + policies for secrets and s3 access should be created ?"
  type        = bool
  default     = true
}

variable "policies_arn" {
  description = "A list of the ARN of the policies you want to apply"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

variable "external_iam_role" {
  description = "The ARN of the role to be attached to the ECS container"
  type        = string
  default     = ""
}

# ECS Service / Task
variable "ecs_cluster_name" {
  description = "The ECS cluster Name"
}

variable "ecs_requires_compatibilities" {
  type        = list(string)
  description = "A list of requires_compatibilities"
  default     = ["FARGATE"]
}

variable "ecs_capacity_provider" {
  description = "Short name of the capacity provider"
  type        = string
  default     = "FARGATE"
}

variable "ecs_service_assign_public_ip" {
  description = "Should be true, if ECS service is using public subnets (more info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html)"
  type        = bool
  default     = false
}

variable "ecs_service_desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "ecs_service_deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  type        = number
  default     = 200
}

variable "ecs_service_deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
  default     = 50
}

variable "ecs_task_cpu" {
  description = "The number of cpu units used by the task"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "The amount (in MiB) of memory used by the task"
  type        = number
  default     = 512
}

variable "ecs_ephemeral_storage_size" {
  description = "The size (in GiB) of storage available to the task"
  type        = number
  default     = 40
}

variable "ecs_ulimits" {
  type = list(object({
    name      = string
    hardLimit = number
    softLimit = number
  }))
  description = "Container ulimit settings. This is a list of maps, where each map should contain \"name\", \"hardLimit\" and \"softLimit\""
  default     = null
}

variable "ecs_pseudo_terminal" {
  type        = bool
  description = "When this parameter is true, a TTY is allocated. "
  default     = null
}

variable "ecs_mount_points" {
  type = list(object({
    containerPath = string
    sourceVolume  = string
    readOnly      = bool
  }))
  description = "(Optional) Container mount points. This is a list of maps, where each map should contain `containerPath`, `sourceVolume` and `readOnly`"
  default     = []
}

variable "ecs_efs_volumes" {
  description = "(Optional) A set of volume blocks that containers in your task may use"
  type = list(object({
    name = string
    efs_volume_configuration = object({
      file_system_id = string
      root_directory = string
      transit_encryption_port = optional(number, 2999)
    })
    authorization_config = object({
      access_point_id = string
      iam = optional(string, "DISABLED")
    })
  }))
  default = []
}

variable "ecs_enable_execute_command" {
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = false
}

variable "ecs_linux_parameters" {
  type = object({
    capabilities = object({
      add  = list(string)
      drop = list(string)
    })
    devices = list(object({
      containerPath = string
      hostPath      = string
      permissions   = list(string)
    }))
    initProcessEnabled = bool
    maxSwap            = number
    sharedMemorySize   = number
    swappiness         = number
    tmpfs = list(object({
      containerPath = string
      mountOptions  = list(string)
      size          = number
    }))
  })
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html"
  default     = null
}

variable "ecs_stop_timeout" {
  type        = number
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own"
  default     = 60
}

variable "container_memory_reservation" {
  description = "The amount of memory (in MiB) to reserve for the container"
  type        = number
  default     = 128
}

variable "custom_container_definitions" {
  description = "A list of valid container definitions provided as a single valid JSON document. By default, the standard container definition is used."
  type        = string
  default     = ""
}

# app
variable "app_port_mapping" {
  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    },
  ]
}

variable "app_ecr_image_repo" {
  description = "The ECR Repository where the app image is located"
  type        = string
  default     = ""
}

variable "app_docker_image" {
  description = "The docker image to be used. If set, app_ecr_image_repo will be ignored"
  type        = string
  default     = ""
}

variable "app_container_command" {
  type        = list(string)
  description = "The command that is passed to the container"
  default     = null
}

variable "app_sg_extra_cidr" {
  type        = list(string)
  description = "A list of extra cidr blocks to allow ingress traffic to container"
  default     = []
}

variable "custom_environment_secrets" {
  description = "List of additional secrets the container will use (list should contain maps with `name` and `valueFrom`)"
  type = list(object(
    {
      name      = string
      valueFrom = string
    }
  ))
  default = []
}

variable "custom_environment_variables" {
  description = "List of additional environment variables the container will use (list should contain maps with `name` and `value`)"
  type = list(object(
    {
      name  = string
      value = string
    }
  ))
  default = []
}

## Service discovery
variable "enable_service_discovery" {
  description = "Whether the service should be registered with Service Discovery. In order to use Service Disovery, an existing DNS Namespace must exist and be passed in."
  type        = bool
  default     = false
}

variable "service_discovery_namespace_id" {
  description = "The ID of the namespace to use for DNS configuration."
  type        = string
  default     = null
}

variable "service_discovery_dns_record_type" {
  description = "The type of the resource, which indicates the value that Amazon Route 53 returns in response to DNS queries. One of `A` or `SRV`."
  type        = string
  default     = "A"
}

variable "service_discovery_dns_ttl" {
  description = "The amount of time, in seconds, that you want DNS resolvers to cache the settings for this resource record set."
  type        = number
  default     = 10
}

variable "service_discovery_routing_policy" {
  description = "The routing policy that you want to apply to all records that Route 53 creates when you register an instance and specify the service. One of `MULTIVALUE` or `WEIGHTED`."
  type        = string
  default     = "MULTIVALUE"
}

variable "service_discovery_failure_threshold" {
  description = "The number of 30-second intervals that you want service discovery to wait before it changes the health status of a service instance. Maximum value of 10."
  type        = number
  default     = 1
}

variable "docker_labels" {
  description = "Docker labels to add to the container"
  type        = map(string)
  default     = {}
}

## Datadog sidecar
variable "enable_datadog_sidecar" {
  description = "Whether the datadog sidecar should be added to the task definition"
  type        = bool
  default     = false
}

variable "enable_datadog_log_forwarder" {
  description = "Whether we create the lambda to forward logs to datadog"
  type        = bool
  default     = false
}

variable "datadog_agent_container_image" {
  description = "The datadog agent sidecar container image"
  default     = "public.ecr.aws/datadog/agent:latest"
}

variable "datadog_agent_container_essential" {
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason"
  type        = bool
  default     = false
}

variable "datadog_firelens_container_image" {
  description = "The datadog firelens sidecar container image"
  default     = "public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"
}

variable "datadog_firelens_container_essential" {
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason"
  type        = bool
  default     = false
}

variable "datadog_service_name" {
  description = "The datadog service name"
  default     = ""
}

variable "datadog_process_collection_enabled" {
  description = "Whether to enable process collection"
  type        = bool
  default     = true
}

variable "datadog_tags" {
  description = " Tags for datadog agent container."
  type        = string
  default     = "env:default, service:default, region:default"
}
