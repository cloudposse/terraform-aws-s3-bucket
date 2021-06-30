locals {
  account_id = data.aws_caller_identity.current.account_id
  principal_names = [
    "arn:aws:iam::${local.account_id}:role/${join("", module.deployment_principal_label.*.id)}",
    "arn:aws:iam::${local.account_id}:role/${join("", module.additional_deployment_principal_label.*.id)}"
  ]
  privileged_principal_arns = var.privileged_principal_enabled ? {
    (local.principal_names[0]) = [""]
    (local.principal_names[1]) = ["prefix1/", "prefix2/"]
  } : {}
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "deployment_iam_policy" {
  count = var.privileged_principal_enabled ? 1 : 0

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${module.this.id}*"
      },
    ]
  })
}

module "deployment_principal_label" {
  count = var.privileged_principal_enabled ? 1 : 0

  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["deployment"]

  context = module.this.context
}

resource "aws_iam_role" "deployment_iam_role" {
  count = var.privileged_principal_enabled ? 1 : 0

  name = join("", module.deployment_principal_label.*.id)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = module.deployment_principal_label[0].tags
}


module "additional_deployment_principal_label" {
  count = var.privileged_principal_enabled ? 1 : 0

  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["deployment", "additional"]

  context = module.this.context
}

resource "aws_iam_role" "additional_deployment_iam_role" {
  count = var.privileged_principal_enabled ? 1 : 0

  name = join("", module.additional_deployment_principal_label.*.id)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = module.this.tags
}

resource "aws_iam_role_policy_attachment" "additional_deployment_role_attachment" {
  count = var.privileged_principal_enabled ? 1 : 0

  policy_arn = join("", aws_iam_policy.deployment_iam_policy.*.arn)
  role       = join("", aws_iam_role.deployment_iam_role.*.name)
}