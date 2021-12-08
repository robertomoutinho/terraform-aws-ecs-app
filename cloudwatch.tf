#####################
## Cloudwatch logs ##
#####################

resource "aws_cloudwatch_log_group" "app" {

  name              = "${var.environment}-${var.name}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = local.local_tags
  kms_key_id        = aws_kms_key.this.arn

}

##################################
## CloudWatch Log Group KMS key ##
##################################

resource "aws_kms_key" "this" {
  description             = "KMS Key for ${var.environment}-${var.name} logs encryption."
  policy                  = data.aws_iam_policy_document.this.json
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    local.local_tags,
    {
      Name = "${var.environment}-${var.name}"
    }
  )
}

resource "aws_kms_alias" "this" {
  name          = format("alias/%s/%s", var.environment, var.name)
  target_key_id = aws_kms_key.this.key_id
}


#################################
## CloudWatch Log Group Policy ##
#################################

data "aws_iam_policy_document" "this" {

  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_109
  statement {
    sid = "AllowCloudWatchLogs01"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        format(
          "logs.%s.amazonaws.com",
          data.aws_region.current.name
        )
      ]
    }

    resources = ["*"]
  }

  statement {
    sid = "EnableIAMUserPermissions"

    actions = [
      "kms:*",
    ]

    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }

    resources = ["*"]
  }
}