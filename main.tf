module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  enabled     = var.enabled
  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
}

resource "aws_s3_bucket" "default" {
  count         = var.enabled ? 1 : 0
  bucket        = module.label.id
  acl           = var.acl
  region        = var.region
  force_destroy = var.force_destroy
  policy        = var.policy

  versioning {
    enabled = var.versioning_enabled
  }

  lifecycle_rule {
    id                                     = module.label.id
    enabled                                = var.lifecycle_rule_enabled
    prefix                                 = var.prefix
    tags                                   = var.lifecycle_tags
    abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days

    noncurrent_version_expiration {
      days = var.noncurrent_version_expiration_days
    }

    dynamic "noncurrent_version_transition" {
      for_each = var.enable_glacier_transition ? [1] : []

      content {
        days          = var.noncurrent_version_transition_days
        storage_class = "GLACIER"
      }
    }

    transition {
      days          = var.standard_transition_days
      storage_class = "STANDARD_IA"
    }

    dynamic "transition" {
      for_each = var.enable_glacier_transition ? [1] : []

      content {
        days          = var.glacier_transition_days
        storage_class = "GLACIER"
      }
    }

    expiration {
      days = var.expiration_days
    }

  }

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
  # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_arn
      }
    }
  }

  tags = module.label.tags
}

module "s3_user" {
  source       = "git::https://github.com/cloudposse/terraform-aws-iam-s3-user.git?ref=tags/0.5.0"
  namespace    = var.namespace
  stage        = var.stage
  environment  = var.environment
  name         = var.name
  attributes   = var.attributes
  tags         = var.tags
  enabled      = var.enabled && var.user_enabled ? true : false
  s3_actions   = var.allowed_bucket_actions
  s3_resources = ["${join("", aws_s3_bucket.default.*.arn)}/*", join("", aws_s3_bucket.default.*.arn)]
}

data "aws_iam_policy_document" "bucket_policy" {
  count = var.enabled && var.allow_encrypted_uploads_only ? 1 : 0

  statement {
    sid       = "DenyIncorrectEncryptionHeader"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${join("", aws_s3_bucket.default.*.id)}/*"]

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
  count  = var.enabled && var.allow_encrypted_uploads_only ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)
  policy = join("", data.aws_iam_policy_document.bucket_policy.*.json)
}

resource "aws_s3_bucket_public_access_block" "default" {
  count = var.enable_block_public_access ? 1 : 0

  bucket              = join("", aws_s3_bucket.default.*.id)
  block_public_acls   = true
  block_public_policy = true
}
