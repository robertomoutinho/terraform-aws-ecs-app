locals {
  version_role_arn = var.get_app_version_role_arn == "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/terraform" : var.get_app_version_role_arn
}

module "app_version" {

  source = "git@github.com:robertomoutinho/tf-aws-ecs-service-version?ref=v0.0.1"

  ecs_cluster_name       = var.ecs_cluster_id
  ecs_service_name       = aws_ecs_service.app.name
  aws_region             = data.aws_region.current.name
  aws_account_id         = data.aws_caller_identity.current.account_id
  aws_execution_role_arn = local.version_role_arn

}