module "datadog_firelens" {

  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.58.1"

  container_name  = "log_router"
  container_image = var.datadog_firelens_container_image
  essential       = var.datadog_firelens_container_essential

  firelens_configuration = {
    type = "fluentbit",
    options = {
      "enable-ecs-log-metadata" = "true",
      "config-file-type" : "file",
      "config-file-value" : "/fluent-bit/configs/parse-json.conf"
    }
  }

}
