#########
## IAM ##
#########

data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  count              = var.create_default_role ? 1 : 0
  name               = "${var.environment}-${var.name}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
  tags               = local.local_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count      = var.create_default_role ? length(var.policies_arn) : 0
  role       = aws_iam_role.ecs_task_execution[0].id
  policy_arn = element(var.policies_arn, count.index)
}

####################
## Secrets Access ##
####################
data "aws_secretsmanager_secret" "creds" {
  count = var.repository_credentials_name != null ? 1 : 0
  name  = var.repository_credentials_name
}

locals {
  secretsmanager_arns = [
    "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:/${local.secret_path}/*",
    "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:/${var.environment}/shared/*"
  ]
}

data "aws_iam_policy_document" "ecs_task_access_secrets" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${local.secret_path}/*",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/shared/*",
    ]
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
  }

  statement {
    effect = "Allow"
    resources = concat(
      local.secretsmanager_arns,
      var.repository_credentials_name != null ? [data.aws_secretsmanager_secret.creds[0].arn] : []
    )
    actions = [
      "secretsmanager:GetSecretValue",
    ]

  }
}

resource "aws_iam_role_policy" "ecs_task_access_secrets" {
  count = var.create_default_role ? 1 : 0
  name  = "ECSTaskAccessSecretsPolicy"
  role  = aws_iam_role.ecs_task_execution[0].id
  policy = element(
    compact(
      concat(
        data.aws_iam_policy_document.ecs_task_access_secrets.*.json,
      ),
    ),
    0,
  )
}

#######################
## S3 Backend Access ##
#######################

data "aws_iam_policy_document" "ecs_task_access_backend" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::*"
    ]
    actions = [
      "s3:*",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_access_backend" {
  count = var.create_default_role ? 1 : 0
  name  = "ECSTaskAccessBackendPolicy"
  role  = aws_iam_role.ecs_task_execution[0].id
  policy = element(
    compact(
      concat(
        data.aws_iam_policy_document.ecs_task_access_backend.*.json,
      ),
    ),
    0,
  )
}
