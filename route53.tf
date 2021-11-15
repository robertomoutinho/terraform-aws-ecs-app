####################
## Route53 record ##
####################

data "aws_route53_zone" "this" {
  count        = var.enable_alb ? 1 : 0
  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_route53_record" "app" {

  count   = var.enable_alb ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.route53_record_name != null ? var.route53_record_name : var.name
  type    = "A"

  alias {
    name                   = module.alb.0.this_lb_dns_name
    zone_id                = module.alb.0.this_lb_zone_id
    evaluate_target_health = true
  }

}