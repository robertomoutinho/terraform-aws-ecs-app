data "aws_vpc" "selected" {
  id = var.vpc_id
}

#####################
## Security groups ##
#####################

module "alb_https_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.18.0"

  name        = "${var.environment}-${var.name}-alb-https"
  vpc_id      = var.vpc_id
  description = "Security group with HTTPS ports open"
  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = var.alb_ingress_cidr_blocks
    },
  ]

  egress_rules = ["all-all"]
  tags         = local.local_tags

}

module "alb_http_sg" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.18.0"

  name        = "${var.environment}-${var.name}-alb-http"
  vpc_id      = var.vpc_id
  description = "Security group with HTTP ports open"
  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = var.alb_ingress_cidr_blocks
    },
  ]

  egress_rules = ["all-all"]
  tags         = local.local_tags

}

#########
## App ##
#########

resource "aws_security_group" "app" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Security group for ${var.environment}-${var.name}"
  vpc_id      = var.vpc_id
  tags        = local.local_tags
}

resource "aws_security_group_rule" "ingress_with_self_rule" {
  security_group_id = aws_security_group.app.id
  type              = "ingress"
  description       = "Ingress with self"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "service_discovery_ingress_rule" {
  for_each          = { for name, config in var.app_port_mapping : name => config }
  security_group_id = aws_security_group.app.id
  type              = "ingress"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  description       = "Service Discovery Ingress"
  from_port         = each.value.hostPort
  to_port           = each.value.hostPort
  protocol          = "tcp"
}

resource "aws_security_group_rule" "ingress_with_alb_https_security_group_id" {
  for_each                 = { for name, config in var.app_port_mapping : name => config }
  security_group_id        = aws_security_group.app.id
  type                     = "ingress"
  source_security_group_id = module.alb_https_sg.this_security_group_id
  description              = "ALB HTTPS"
  from_port                = each.value.hostPort
  to_port                  = each.value.hostPort
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "ingress_with_alb_http_security_group_id" {
  for_each                 = { for name, config in var.app_port_mapping : name => config }
  security_group_id        = aws_security_group.app.id
  type                     = "ingress"
  source_security_group_id = module.alb_http_sg.this_security_group_id
  description              = "ALB HTTP"
  from_port                = each.value.hostPort
  to_port                  = each.value.hostPort
  protocol                 = "tcp"
}