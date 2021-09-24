####################
## Route53 record ##
####################

data "aws_route53_zone" "this" {
  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_route53_record" "app" {

  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.route53_record_name != null ? var.route53_record_name : var.name
  type    = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }

}