# AWS Terraform module which runs an web app on AWS Fargate

This repository contains Terraform infrastructure code which creates AWS resources required to run an web app on AWS, including:

- AWS Application Load Balancer (ALB)
- AWS Route53 domain name pointing to ALB
- [AWS Elastic Cloud Service (ECS)](https://aws.amazon.com/ecs/) task running on [AWS Fargate](https://aws.amazon.com/fargate/) (with the provided docker image)
- AWS Service Discovery
- AWS IAM necessary to access other AWS resources (such as S3, SNS and etc)
- AWS Cloudwatch for the logs

[![Checkov](https://github.com/robertomoutinho/terraform-aws-ecs-app/actions/workflows/checkov.yml/badge.svg)](https://github.com/robertomoutinho/terraform-aws-ecs-app/actions/workflows/checkov.yml)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.46.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.46.0, < 5.0 |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | 5.16.0 |
| <a name="module_alb_http_sg"></a> [alb\_http\_sg](#module\_alb\_http\_sg) | terraform-aws-modules/security-group/aws | v3.18.0 |
| <a name="module_alb_https_sg"></a> [alb\_https\_sg](#module\_alb\_https\_sg) | terraform-aws-modules/security-group/aws | v3.18.0 |
| <a name="module_container_definition"></a> [container\_definition](#module\_container\_definition) | cloudposse/ecs-container-definition/aws | v0.58.1 |
| <a name="module_datadog_firelens"></a> [datadog\_firelens](#module\_datadog\_firelens) | cloudposse/ecs-container-definition/aws | v0.58.1 |
| <a name="module_datadog_sidecar"></a> [datadog\_sidecar](#module\_datadog\_sidecar) | cloudposse/ecs-container-definition/aws | v0.58.1 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.auto_scaling_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.auto_scaling_mem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task_access_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_access_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.allow_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.force_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.nlb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.extra_certs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_target_group.nlb_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_extra_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_with_alb_http_security_group_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_with_alb_https_security_group_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_with_self_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.service_discovery_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_service.sds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_iam_policy_document.ecs_task_access_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_access_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_secretsmanager_secret.creds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [external_external.current_image](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_extra_acm_cert_arn"></a> [alb\_extra\_acm\_cert\_arn](#input\_alb\_extra\_acm\_cert\_arn) | The ARN of the ACM SSL certificate for the extra cert | `list(string)` | `[]` | no |
| <a name="input_alb_extra_security_group_ids"></a> [alb\_extra\_security\_group\_ids](#input\_alb\_extra\_security\_group\_ids) | List of one or more security groups to be added to the load balancer | `list(string)` | `[]` | no |
| <a name="input_alb_extra_target_groups"></a> [alb\_extra\_target\_groups](#input\_alb\_extra\_target\_groups) | List of one or more target groups to be added to the load balancer | `list(string)` | `[]` | no |
| <a name="input_alb_ingress_cidr_blocks"></a> [alb\_ingress\_cidr\_blocks](#input\_alb\_ingress\_cidr\_blocks) | Comma separated string of IPv4 CIDR ranges to use on all ingress rules of the ALB. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Whether the load balancer is internal or external | `bool` | `false` | no |
| <a name="input_alb_log_bucket_name"></a> [alb\_log\_bucket\_name](#input\_alb\_log\_bucket\_name) | S3 bucket (externally created) for storing load balancer access logs. Required if alb\_logging\_enabled is true. | `string` | `""` | no |
| <a name="input_alb_log_location_prefix"></a> [alb\_log\_location\_prefix](#input\_alb\_log\_location\_prefix) | S3 prefix within the log\_bucket\_name under which logs are stored. | `string` | `""` | no |
| <a name="input_alb_logging_enabled"></a> [alb\_logging\_enabled](#input\_alb\_logging\_enabled) | Controls if the ALB will log requests to S3. | `bool` | `false` | no |
| <a name="input_app_container_command"></a> [app\_container\_command](#input\_app\_container\_command) | The command that is passed to the container | `list(string)` | `null` | no |
| <a name="input_app_docker_image"></a> [app\_docker\_image](#input\_app\_docker\_image) | The docker image to be used. If set, app\_ecr\_image\_repo will be ignored | `string` | `""` | no |
| <a name="input_app_ecr_image_repo"></a> [app\_ecr\_image\_repo](#input\_app\_ecr\_image\_repo) | The ECR Repository where the app image is located | `string` | `""` | no |
| <a name="input_app_fqdn"></a> [app\_fqdn](#input\_app\_fqdn) | FQDN of app to use. Set this only to override Route53 and ALB's DNS name. | `string` | `null` | no |
| <a name="input_app_port_mapping"></a> [app\_port\_mapping](#input\_app\_port\_mapping) | The port mappings to configure for the container. This is a list of maps. Each map should contain "containerPort", "hostPort", and "protocol", where "protocol" is one of "tcp" or "udp". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort | <pre>list(object({<br>    containerPort = number<br>    hostPort      = number<br>    protocol      = string<br>  }))</pre> | <pre>[<br>  {<br>    "containerPort": 80,<br>    "hostPort": 80,<br>    "protocol": "tcp"<br>  }<br>]</pre> | no |
| <a name="input_app_sg_extra_cidr"></a> [app\_sg\_extra\_cidr](#input\_app\_sg\_extra\_cidr) | A list of extra cidr blocks to allow ingress traffic to container | `list(string)` | `[]` | no |
| <a name="input_asg_cooldown_to_scale_down_again"></a> [asg\_cooldown\_to\_scale\_down\_again](#input\_asg\_cooldown\_to\_scale\_down\_again) | The amount of time, in seconds, after a scaling activity completes and before the next scaling down activity can start. | `number` | `300` | no |
| <a name="input_asg_cooldown_to_scale_up_again"></a> [asg\_cooldown\_to\_scale\_up\_again](#input\_asg\_cooldown\_to\_scale\_up\_again) | The amount of time, in seconds, after a scaling activity completes and before the next scaling up activity can start. | `number` | `60` | no |
| <a name="input_asg_evaluation_periods"></a> [asg\_evaluation\_periods](#input\_asg\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold. | `number` | `5` | no |
| <a name="input_asg_max_tasks"></a> [asg\_max\_tasks](#input\_asg\_max\_tasks) | The amount of maximum tasks | `number` | `3` | no |
| <a name="input_asg_min_tasks"></a> [asg\_min\_tasks](#input\_asg\_min\_tasks) | The amount of minimum tasks | `number` | `1` | no |
| <a name="input_asg_period"></a> [asg\_period](#input\_asg\_period) | The period in seconds over which the specified statistic is applied | `number` | `60` | no |
| <a name="input_asg_threshold_cpu_to_scale_down"></a> [asg\_threshold\_cpu\_to\_scale\_down](#input\_asg\_threshold\_cpu\_to\_scale\_down) | The value against which the specified statistic is compared. | `number` | `40` | no |
| <a name="input_asg_threshold_cpu_to_scale_up"></a> [asg\_threshold\_cpu\_to\_scale\_up](#input\_asg\_threshold\_cpu\_to\_scale\_up) | The value against which the specified statistic is compared. | `number` | `60` | no |
| <a name="input_asg_threshold_mem_to_scale_down"></a> [asg\_threshold\_mem\_to\_scale\_down](#input\_asg\_threshold\_mem\_to\_scale\_down) | The value against which the specified statistic is compared. | `number` | `40` | no |
| <a name="input_asg_threshold_mem_to_scale_up"></a> [asg\_threshold\_mem\_to\_scale\_up](#input\_asg\_threshold\_mem\_to\_scale\_up) | The value against which the specified statistic is compared. | `number` | `60` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of certificate issued by AWS ACM. | `string` | `""` | no |
| <a name="input_cloudwatch_log_retention_in_days"></a> [cloudwatch\_log\_retention\_in\_days](#input\_cloudwatch\_log\_retention\_in\_days) | Retention period of app CloudWatch logs | `number` | `7` | no |
| <a name="input_container_memory_reservation"></a> [container\_memory\_reservation](#input\_container\_memory\_reservation) | The amount of memory (in MiB) to reserve for the container | `number` | `128` | no |
| <a name="input_create_default_role"></a> [create\_default\_role](#input\_create\_default\_role) | Default role + policies for secrets and s3 access should be created ? | `bool` | `true` | no |
| <a name="input_create_route53_record"></a> [create\_route53\_record](#input\_create\_route53\_record) | Whether to create Route53 record for app | `bool` | `true` | no |
| <a name="input_custom_container_definitions"></a> [custom\_container\_definitions](#input\_custom\_container\_definitions) | A list of valid container definitions provided as a single valid JSON document. By default, the standard container definition is used. | `string` | `""` | no |
| <a name="input_custom_environment_secrets"></a> [custom\_environment\_secrets](#input\_custom\_environment\_secrets) | List of additional secrets the container will use (list should contain maps with `name` and `valueFrom`) | <pre>list(object(<br>    {<br>      name      = string<br>      valueFrom = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_custom_environment_variables"></a> [custom\_environment\_variables](#input\_custom\_environment\_variables) | List of additional environment variables the container will use (list should contain maps with `name` and `value`) | <pre>list(object(<br>    {<br>      name  = string<br>      value = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_datadog_agent_container_essential"></a> [datadog\_agent\_container\_essential](#input\_datadog\_agent\_container\_essential) | Determines whether all other containers in a task are stopped, if this container fails or stops for any reason | `bool` | `false` | no |
| <a name="input_datadog_agent_container_image"></a> [datadog\_agent\_container\_image](#input\_datadog\_agent\_container\_image) | The datadog agent sidecar container image | `string` | `"datadog/agent:latest"` | no |
| <a name="input_datadog_agent_integrations"></a> [datadog\_agent\_integrations](#input\_datadog\_agent\_integrations) | The datadog agent integrations, see Docker (AD v2) at https://docs.datadoghq.com/containers/docker/integrations/?tab=dockeradv2 | <pre>list(object({<br>    name   = string<br>    config = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| <a name="input_datadog_firelens_container_essential"></a> [datadog\_firelens\_container\_essential](#input\_datadog\_firelens\_container\_essential) | Determines whether all other containers in a task are stopped, if this container fails or stops for any reason | `bool` | `false` | no |
| <a name="input_datadog_firelens_container_image"></a> [datadog\_firelens\_container\_image](#input\_datadog\_firelens\_container\_image) | The datadog firelens sidecar container image | `string` | `"amazon/aws-for-fluent-bit:stable"` | no |
| <a name="input_datadog_service_name"></a> [datadog\_service\_name](#input\_datadog\_service\_name) | The datadog service name | `string` | `""` | no |
| <a name="input_datadog_tags"></a> [datadog\_tags](#input\_datadog\_tags) | Tags for datadog agent container. | `string` | `"env:default, service:default, region:default"` | no |
| <a name="input_ecs_capacity_provider"></a> [ecs\_capacity\_provider](#input\_ecs\_capacity\_provider) | Short name of the capacity provider | `string` | `"FARGATE"` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | The ECS cluster Name | `any` | n/a | yes |
| <a name="input_ecs_efs_volumes"></a> [ecs\_efs\_volumes](#input\_ecs\_efs\_volumes) | (Optional) A set of volume blocks that containers in your task may use | <pre>list(object({<br>    name = string<br>    efs_volume_configuration = object({<br>      file_system_id = string<br>      root_directory = string<br>    })<br>    authorization_config = object({<br>      access_point_id = string<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_ecs_enable_execute_command"></a> [ecs\_enable\_execute\_command](#input\_ecs\_enable\_execute\_command) | Specifies whether to enable Amazon ECS Exec for the tasks within the service | `bool` | `false` | no |
| <a name="input_ecs_ephemeral_storage_size"></a> [ecs\_ephemeral\_storage\_size](#input\_ecs\_ephemeral\_storage\_size) | The size (in GiB) of storage available to the task | `number` | `40` | no |
| <a name="input_ecs_linux_parameters"></a> [ecs\_linux\_parameters](#input\_ecs\_linux\_parameters) | Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html | <pre>object({<br>    capabilities = object({<br>      add  = list(string)<br>      drop = list(string)<br>    })<br>    devices = list(object({<br>      containerPath = string<br>      hostPath      = string<br>      permissions   = list(string)<br>    }))<br>    initProcessEnabled = bool<br>    maxSwap            = number<br>    sharedMemorySize   = number<br>    swappiness         = number<br>    tmpfs = list(object({<br>      containerPath = string<br>      mountOptions  = list(string)<br>      size          = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_ecs_mount_points"></a> [ecs\_mount\_points](#input\_ecs\_mount\_points) | (Optional) Container mount points. This is a list of maps, where each map should contain `containerPath`, `sourceVolume` and `readOnly` | <pre>list(object({<br>    containerPath = string<br>    sourceVolume  = string<br>    readOnly      = bool<br>  }))</pre> | `[]` | no |
| <a name="input_ecs_pseudo_terminal"></a> [ecs\_pseudo\_terminal](#input\_ecs\_pseudo\_terminal) | When this parameter is true, a TTY is allocated. | `bool` | `null` | no |
| <a name="input_ecs_requires_compatibilities"></a> [ecs\_requires\_compatibilities](#input\_ecs\_requires\_compatibilities) | A list of requires\_compatibilities | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_ecs_service_assign_public_ip"></a> [ecs\_service\_assign\_public\_ip](#input\_ecs\_service\_assign\_public\_ip) | Should be true, if ECS service is using public subnets (more info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html) | `bool` | `false` | no |
| <a name="input_ecs_service_deployment_maximum_percent"></a> [ecs\_service\_deployment\_maximum\_percent](#input\_ecs\_service\_deployment\_maximum\_percent) | The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment | `number` | `200` | no |
| <a name="input_ecs_service_deployment_minimum_healthy_percent"></a> [ecs\_service\_deployment\_minimum\_healthy\_percent](#input\_ecs\_service\_deployment\_minimum\_healthy\_percent) | The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment | `number` | `50` | no |
| <a name="input_ecs_service_desired_count"></a> [ecs\_service\_desired\_count](#input\_ecs\_service\_desired\_count) | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| <a name="input_ecs_stop_timeout"></a> [ecs\_stop\_timeout](#input\_ecs\_stop\_timeout) | Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own | `number` | `60` | no |
| <a name="input_ecs_task_cpu"></a> [ecs\_task\_cpu](#input\_ecs\_task\_cpu) | The number of cpu units used by the task | `number` | `256` | no |
| <a name="input_ecs_task_memory"></a> [ecs\_task\_memory](#input\_ecs\_task\_memory) | The amount (in MiB) of memory used by the task | `number` | `512` | no |
| <a name="input_ecs_ulimits"></a> [ecs\_ulimits](#input\_ecs\_ulimits) | Container ulimit settings. This is a list of maps, where each map should contain "name", "hardLimit" and "softLimit" | <pre>list(object({<br>    name      = string<br>    hardLimit = number<br>    softLimit = number<br>  }))</pre> | `null` | no |
| <a name="input_enable_alb"></a> [enable\_alb](#input\_enable\_alb) | IF an application load balancer should be created | `bool` | `true` | no |
| <a name="input_enable_asg"></a> [enable\_asg](#input\_enable\_asg) | If autoscaling should be enabled | `bool` | `false` | no |
| <a name="input_enable_datadog_log_forwarder"></a> [enable\_datadog\_log\_forwarder](#input\_enable\_datadog\_log\_forwarder) | Whether we create the lambda to forward logs to datadog | `bool` | `false` | no |
| <a name="input_enable_datadog_sidecar"></a> [enable\_datadog\_sidecar](#input\_enable\_datadog\_sidecar) | Whether the datadog sidecar should be added to the task definition | `bool` | `false` | no |
| <a name="input_enable_nlb"></a> [enable\_nlb](#input\_enable\_nlb) | IF an network load balancer should be created | `bool` | `true` | no |
| <a name="input_enable_service_discovery"></a> [enable\_service\_discovery](#input\_enable\_service\_discovery) | Whether the service should be registered with Service Discovery. In order to use Service Disovery, an existing DNS Namespace must exist and be passed in. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | n/a | yes |
| <a name="input_external_iam_role"></a> [external\_iam\_role](#input\_external\_iam\_role) | The ARN of the role to be attached to the ECS container | `string` | `""` | no |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | Healthcheck interval | `number` | `3` | no |
| <a name="input_health_check_http_code_matcher"></a> [health\_check\_http\_code\_matcher](#input\_health\_check\_http\_code\_matcher) | Healthcheck interval | `string` | `"200-399"` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Healthcheck interval | `number` | `15` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Healthcheck interval | `string` | `"/"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Healthcheck interval | `number` | `5` | no |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | Healthcheck interval | `number` | `4` | no |
| <a name="input_iam_role_for_external_datasource"></a> [iam\_role\_for\_external\_datasource](#input\_iam\_role\_for\_external\_datasource) | This Role is used to get the current app version deploy to ECS | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to use on all resources created (VPC, ALB, etc) | `string` | `"app"` | no |
| <a name="input_policies_arn"></a> [policies\_arn](#input\_policies\_arn) | A list of the ARN of the policies you want to apply | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"<br>]</pre> | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | A list of IDs of existing private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | A list of IDs of existing public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_repository_credentials_name"></a> [repository\_credentials\_name](#input\_repository\_credentials\_name) | The SecretsManager Secret Name of the repository credentials to use | `string` | `null` | no |
| <a name="input_route53_record_name"></a> [route53\_record\_name](#input\_route53\_record\_name) | Name of Route53 record to create ACM certificate in and main A-record. If null is specified, var.name is used instead. Provide empty string to point root domain name to ALB. | `string` | `null` | no |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Route53 zone name to create ACM certificate in and main A-record, without trailing dot | `string` | `""` | no |
| <a name="input_secret_path"></a> [secret\_path](#input\_secret\_path) | path to append to IAM secrets access policy | `string` | `""` | no |
| <a name="input_service_discovery_dns_record_type"></a> [service\_discovery\_dns\_record\_type](#input\_service\_discovery\_dns\_record\_type) | The type of the resource, which indicates the value that Amazon Route 53 returns in response to DNS queries. One of `A` or `SRV`. | `string` | `"A"` | no |
| <a name="input_service_discovery_dns_ttl"></a> [service\_discovery\_dns\_ttl](#input\_service\_discovery\_dns\_ttl) | The amount of time, in seconds, that you want DNS resolvers to cache the settings for this resource record set. | `number` | `10` | no |
| <a name="input_service_discovery_failure_threshold"></a> [service\_discovery\_failure\_threshold](#input\_service\_discovery\_failure\_threshold) | The number of 30-second intervals that you want service discovery to wait before it changes the health status of a service instance. Maximum value of 10. | `number` | `1` | no |
| <a name="input_service_discovery_namespace_id"></a> [service\_discovery\_namespace\_id](#input\_service\_discovery\_namespace\_id) | The ID of the namespace to use for DNS configuration. | `string` | `null` | no |
| <a name="input_service_discovery_routing_policy"></a> [service\_discovery\_routing\_policy](#input\_service\_discovery\_routing\_policy) | The routing policy that you want to apply to all records that Route 53 creates when you register an instance and specify the service. One of `MULTIVALUE` or `WEIGHTED`. | `string` | `"MULTIVALUE"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to use on all resources | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of an existing VPC where resources will be created | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | Dns name of alb |
| <a name="output_alb_https_tcp_listener_arns"></a> [alb\_https\_tcp\_listener\_arns](#output\_alb\_https\_tcp\_listener\_arns) | The ARNs of the HTTPS load balancer listeners created. |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | The ID and ARN of the application load balancer created |
| <a name="output_alb_target_group_arns"></a> [alb\_target\_group\_arns](#output\_alb\_target\_group\_arns) | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | Zone ID of alb |
| <a name="output_cloudwatch_group_name"></a> [cloudwatch\_group\_name](#output\_cloudwatch\_group\_name) | The AWS cloudwatch group name |
| <a name="output_ecs_security_group"></a> [ecs\_security\_group](#output\_ecs\_security\_group) | Security group assigned to ECS Service in network configuration |
| <a name="output_ecs_task_definition"></a> [ecs\_task\_definition](#output\_ecs\_task\_definition) | Task definition for ECS service (used for external triggers) |
| <a name="output_nlb_dns_name"></a> [nlb\_dns\_name](#output\_nlb\_dns\_name) | Dns name of nlb |
| <a name="output_nlb_id"></a> [nlb\_id](#output\_nlb\_id) | The ID and ARN of the network load balancer created |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | The app ECS task role arn |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC that was created or passed in |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
