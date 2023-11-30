#########
## ALB ##
#########

module "alb" {

  count   = var.enable_alb ? 1 : 0
  source  = "terraform-aws-modules/alb/aws"
  version = "5.16.0"

  name     = "${var.environment}-${var.name}"
  internal = var.alb_internal

  vpc_id          = var.vpc_id
  subnets         = var.public_subnet_ids
  security_groups = flatten([module.alb_https_sg.this_security_group_id, module.alb_http_sg.this_security_group_id, var.alb_extra_security_group_ids])

  access_logs = {
    enabled = var.alb_logging_enabled
    bucket  = var.alb_log_bucket_name
    prefix  = var.alb_log_location_prefix
  }

  https_listeners = [
    {
      target_group_index = 0
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.certificate_arn
      action_type        = "forward"
    },
  ]

  target_groups = [
    {
      name                 = "${var.environment}-${var.name}"
      backend_protocol     = "HTTP"
      backend_port         = var.app_port_mapping.0.containerPort
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = var.health_check_interval
        path                = var.health_check_path
        port                = var.app_port_mapping.0.containerPort
        healthy_threshold   = var.health_check_healthy_threshold
        unhealthy_threshold = var.health_check_unhealthy_threshold
        timeout             = var.health_check_timeout
        protocol            = "HTTP"
        matcher             = var.health_check_http_code_matcher
      }
    },
  ]

  tags = local.local_tags

}

# HTTPS redirects are enabled only for public facing ALB
resource "aws_lb_listener" "allow_http" {
  count             = (var.enable_alb == true && var.alb_internal == false) ? 1 : 0
  load_balancer_arn = module.alb.0.this_lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.alb.0.target_group_arns[0]
  }
}

# Allow non-encrypted traffic for internal ALB onb port 80
resource "aws_lb_listener" "force_https" {
  count             = (var.enable_alb == true && var.alb_internal == true) ? 1 : 0
  load_balancer_arn = module.alb.0.this_lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

## Attach extra ACM SSL certificates
resource "aws_lb_listener_certificate" "extra_certs" {
  for_each        = length(compact(var.alb_extra_acm_cert_arn)) == 0 || var.enable_alb == false ? [] : toset(var.alb_extra_acm_cert_arn)
  listener_arn    = module.alb.0.https_listener_arns[0]
  certificate_arn = each.key
}