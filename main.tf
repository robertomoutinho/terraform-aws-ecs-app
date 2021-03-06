data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {

  local_tags = merge(
    {
      Name        = var.name,
      System      = "app",
      Environment = var.environment
    },
    var.tags,
  )

  secret_path = var.secret_path != "" ? var.secret_path : "${var.environment}/${var.name}"

}