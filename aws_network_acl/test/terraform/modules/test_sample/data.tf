data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

data "aws_caller_identity" "current" {}

locals {
  current_aws_iam_principal = {
    arn       = data.aws_caller_identity.current.arn
    unique_id = data.aws_caller_identity.current.user_id
  }
}


