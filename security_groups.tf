#####################
## Security groups ##
#####################

module "alb_https_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.18.0"

  name        = "${var.name}-alb-https"
  vpc_id      = var.vpc_id
  description = "Security group with HTTPS ports open"
  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = var.alb_ingress_cidr_blocks
    },
  ]
  tags = local.local_tags

}

module "alb_http_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.18.0"

  name        = "${var.name}-alb-http"
  vpc_id      = var.vpc_id
  description = "Security group with HTTP ports open"
  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = var.alb_ingress_cidr_blocks
    },
  ]
  tags = local.local_tags

}

module "app_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.18.0"

  name        = var.name
  vpc_id      = var.vpc_id
  description = "Security group with open port for app (${var.app_port}) from ALB, egress ports are all world open"

  ingress_with_source_security_group_id = [
    {
      from_port                = var.app_port
      to_port                  = var.app_port
      protocol                 = "tcp"
      description              = "app"
      source_security_group_id = module.alb_https_sg.this_security_group_id
    },
  ]

  egress_rules = ["all-all"]

  tags = local.local_tags

}