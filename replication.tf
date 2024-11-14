resource "aws_iam_role" "replication" {
  count = local.replication_enabled ? 1 : 0

  name                 = format("%s-replication", local.bucket_name)
  assume_role_policy   = data.aws_iam_policy_document.replication_sts[0].json
  permissions_boundary = var.s3_replication_permissions_boundary_arn

  tags = module.this.tags
}

data "aws_iam_policy_document" "replication_sts" {
  count = local.replication_enabled ? 1 : 0

  statement {
    sid    = "AllowPrimaryToAssumeServiceRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "replication" {
  count = local.replication_enabled ? 1 : 0

  name   = aws_iam_role.replication[0].name
  policy = data.aws_iam_policy_document.replication[0].json

  tags = module.this.tags
}

data "aws_iam_policy_document" "replication" {
  count = local.replication_enabled ? 1 : 0

  statement {
    sid    = "AllowPrimaryToGetReplicationConfiguration"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.default[0].arn,
      "${aws_s3_bucket.default[0].arn}/*"
    ]
  }

  statement {
    sid    = "AllowPrimaryToReplicate"
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetObjectVersionTagging",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]

    resources = toset(concat(
      try(length(var.s3_replica_bucket_arn), 0) > 0 ? ["${var.s3_replica_bucket_arn}/*"] : [],
      [for rule in local.s3_replication_rules : "${rule.destination_bucket}/*" if try(length(rule.destination_bucket), 0) > 0],
      [for rule in local.s3_replication_rules : "${rule.destination.bucket}/*" if try(length(rule.destination.bucket), 0) > 0],
    ))
  }
}

resource "aws_iam_role_policy_attachment" "replication" {
  count      = local.replication_enabled ? 1 : 0
  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}
