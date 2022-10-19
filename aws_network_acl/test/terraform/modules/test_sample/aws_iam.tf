resource "aws_iam_role" "these" {
  for_each = toset([
    "sample",
  ])

  name = replace("${local.resource_name_prefix}-${each.value}", "_", "-")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = local.current_aws_iam_principal.arn
        }
      },
    ]
  })
}
