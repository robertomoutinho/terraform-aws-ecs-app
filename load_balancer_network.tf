####################################
## Internal network load balancer ##
####################################

resource "aws_lb" "nlb" {
  count                      = var.enable_nlb ? 1 : 0
  name                       = "${var.environment}-${var.name}-nlb"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = var.private_subnet_ids
  enable_deletion_protection = false
  tags                       = local.local_tags
}

resource "aws_lb_target_group" "nlb_tg" {
  count       = var.enable_nlb ? 1 : 0
  name        = "${var.environment}-${var.name}-nlb-tg"
  port        = var.app_port_mapping.0.containerPort
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

# Redirect all traffic from the NLB to the target group
resource "aws_lb_listener" "nlb_listener" {
  count             = var.enable_nlb ? 1 : 0
  load_balancer_arn = aws_lb.nlb.0.id
  port              = var.app_port_mapping.0.containerPort
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.nlb_tg.0.id
    type             = "forward"
  }
}