# data "aws_secretsmanager_secret" "datadog_api_key_secret" {
#   count = var.enable_datadog_log_forwarder && var.datadog_log_forwarder_type == "CLOUDWATCH" ? 1 : 0
#   name  = "/datadog/api_key"
# }

# data "aws_secretsmanager_secret_version" "datadog_api_key_secret" {
#   count     = var.enable_datadog_log_forwarder && var.datadog_log_forwarder_type == "CLOUDWATCH" ? 1 : 0
#   secret_id = data.aws_secretsmanager_secret.datadog_api_key_secret.0.id
# }

# // For more information regarding this log forwarder:
# // https://docs.datadoghq.com/serverless/libraries_integrations/forwarder/
# resource "aws_cloudformation_stack" "datadog_forwarder" {
#   #checkov:skip=CKV_AWS_124:Ensure that CloudFormation stacks are sending event notifications to an SNS topic
#   count        = var.enable_datadog_log_forwarder && var.datadog_log_forwarder_type == "CLOUDWATCH" ? 1 : 0
#   name         = "${var.environment}-${var.name}-datadog-forwarder"
#   capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
#   parameters = {
#     DdApiKeySecretArn = data.aws_secretsmanager_secret.datadog_api_key_secret.0.arn
#     #checkov:skip=CKV_SECRET_6:Base64 High Entropy String
#     DdApiKey            = "this_value_is_not_used"
#     DdTags              = "env:${var.environment},service:${var.name},region:${data.aws_region.current.name}"
#     FunctionName        = "${var.environment}-${var.name}-datadog-forwarder"
#     ReservedConcurrency = 20
#   }

#   template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"

#   lifecycle {
#     ignore_changes = [
#       parameters["DdApiKey"],
#     ]
#   }

#   tags = local.local_tags

# }

# resource "aws_cloudwatch_log_subscription_filter" "app_lambdafunction_logfilter" {
#   count           = var.enable_datadog_log_forwarder && var.datadog_log_forwarder_type == "CLOUDWATCH" ? 1 : 0
#   name            = "${aws_cloudwatch_log_group.app.name}-filter"
#   log_group_name  = aws_cloudwatch_log_group.app.name
#   filter_pattern  = ""
#   destination_arn = aws_cloudformation_stack.datadog_forwarder.0.outputs.DatadogForwarderArn
#   distribution    = "Random"
# }

# resource "aws_lambda_permission" "allow_app_cloudwatch_logs_to_call_dd_lambda_handler" {
#   count         = var.enable_datadog_log_forwarder && var.datadog_log_forwarder_type == "CLOUDWATCH" ? 1 : 0
#   statement_id  = "${replace(aws_cloudwatch_log_group.app.name, "/", "_")}-AllowExecutionFromCloudWatchLogs"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_cloudformation_stack.datadog_forwarder.0.outputs.DatadogForwarderArn
#   principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
#   source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.app.name}:*"
# }