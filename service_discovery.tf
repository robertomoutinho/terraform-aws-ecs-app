resource "aws_service_discovery_service" "sds" {

  count = var.enable_service_discovery ? 1 : 0

  name = "${var.environment}-${var.name}"

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = var.service_discovery_dns_ttl
      type = var.service_discovery_dns_record_type
    }

    routing_policy = var.service_discovery_routing_policy
  }

  health_check_custom_config {
    failure_threshold = var.service_discovery_failure_threshold
  }

}