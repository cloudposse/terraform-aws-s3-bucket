module "default_label" {
  source     = "git::https://github.com/rverma-nikiai/terraform-null-label.git?ref=master"
  enabled    = var.enabled
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "aws_s3_bucket" "default" {
  count         = var.enabled == "true" ? 1 : 0
  bucket        = module.default_label.id
  acl           = var.acl
  region        = var.region
  force_destroy = var.force_destroy
  policy        = var.policy

  versioning {
    enabled = var.versioning_enabled
  }

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
  # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_id
      }
    }
  }

  tags = module.default_label.tags
}

module "s3_user" {
  source       = "git::https://github.com/rverma-nikiai/terraform-aws-iam-s3-user.git?ref=master"
  namespace    = var.namespace
  stage        = var.stage
  name         = var.name
  attributes   = var.attributes
  tags         = var.tags
  enabled      = var.enabled == "true" && var.user_enabled == "true" ? "true" : "false"
  s3_actions   = [var.allowed_bucket_actions]
  s3_resources = ["${join("", aws_s3_bucket.default.*.arn)}/*", join("", aws_s3_bucket.default.*.arn)]
}

data "aws_iam_policy_document" "bucket_policy" {
  count = var.enabled == "true" && var.allow_encrypted_uploads_only == "true" ? 1 : 0

  statement {
    sid       = "DenyIncorrectEncryptionHeader"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.default[0].id}/*"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "StringNotEquals"
      values   = [var.sse_algorithm]
      variable = "s3:x-amz-server-side-encryption"
    }
  }

  statement {
    sid       = "DenyUnEncryptedObjectUploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.default[0].id}/*"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "Null"
      values   = ["true"]
      variable = "s3:x-amz-server-side-encryption"
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  count  = var.enabled == "true" && var.allow_encrypted_uploads_only == "true" ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  policy = join("", data.aws_iam_policy_document.bucket_policy.*.json)
}

