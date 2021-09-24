data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {

  # app
  app_image = var.app_image

  app_url = "https://${coalesce(
    var.app_fqdn,
    element(concat(aws_route53_record.app.*.fqdn, [""]), 0),
    module.alb.this_lb_dns_name,
    "_"
  )}"

  app_url_events = "${local.app_url}/events"

  container_definition_environment = [
  ]

  local_tags = merge(
    {
      Name        = var.name,
      System      = "app",
      Environment = var.environment
    },
    var.tags,
  )

}