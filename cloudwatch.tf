#####################
## Cloudwatch logs ##
#####################

resource "aws_cloudwatch_log_group" "app" {

  name              = var.name
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = local.local_tags

}
