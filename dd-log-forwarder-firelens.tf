module "datadog_firelens" {
    
    source  = "cloudposse/ecs-container-definition/aws"
    version = "v0.58.1"

    container_name  = "log_router"
    container_image = var.datadog_firelens_container_image

    firelens_configuration = {
        type = "fluentbit",
        options = { "enable-ecs-log-metadata" = "true" }
    }

}