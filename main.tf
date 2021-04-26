locals {
  bucket_name = var.bucket_name != null && var.bucket_name != "" ? var.bucket_name : module.this.id
}

resource "aws_s3_bucket" "default" {
  #bridgecrew:skip=BC_AWS_S3_13:Skipping `Enable S3 Bucket Logging` because we do not have good defaults
  #bridgecrew:skip=CKV_AWS_52:Skipping `Ensure S3 bucket has MFA delete enabled` due to issue in terraform (https://github.com/hashicorp/terraform-provider-aws/issues/629).
  #bridgecrew:skip=BC_AWS_S3_16:Skipping `Ensure S3 bucket versioning is enabled` because dynamic blocks are not supported by checkov
  #bridgecrew:skip=BC_AWS_S3_14:Skipping `Ensure all data stored in the S3 bucket is securely encrypted at rest` because variables are not understood
  count         = module.this.enabled ? 1 : 0
  bucket        = local.bucket_name
  acl           = try(length(var.grants), 0) == 0 ? var.acl : null
  force_destroy = var.force_destroy
  tags          = module.this.tags

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      enabled                                = lifecycle_rule.value.enabled
      prefix                                 = lifecycle_rule.value.prefix
      tags                                   = lifecycle_rule.value.tags
      abort_incomplete_multipart_upload_days = lifecycle_rule.value.abort_incomplete_multipart_upload_days

      noncurrent_version_expiration {
        days = lifecycle_rule.value.noncurrent_version_expiration_days
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.enable_glacier_transition ? [1] : []

        content {
          days          = lifecycle_rule.value.noncurrent_version_glacier_transition_days
          storage_class = "GLACIER"
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.enable_deeparchive_transition ? [1] : []

        content {
          days          = lifecycle_rule.value.noncurrent_version_deeparchive_transition_days
          storage_class = "DEEP_ARCHIVE"
        }
      }

      dynamic "transition" {
        for_each = lifecycle_rule.value.enable_glacier_transition ? [1] : []

        content {
          days          = lifecycle_rule.value.glacier_transition_days
          storage_class = "GLACIER"
        }
      }

      dynamic "transition" {
        for_each = lifecycle_rule.value.enable_deeparchive_transition ? [1] : []

        content {
          days          = lifecycle_rule.value.deeparchive_transition_days
          storage_class = "DEEP_ARCHIVE"
        }
      }



      dynamic "transition" {
        for_each = lifecycle_rule.value.enable_standard_ia_transition ? [1] : []

        content {
          days          = lifecycle_rule.value.standard_transition_days
          storage_class = "STANDARD_IA"
        }
      }

      dynamic "expiration" {
        for_each = lifecycle_rule.value.enable_current_object_expiration ? [1] : []

        content {
          days = lifecycle_rule.value.expiration_days
        }
      }
    }
  }

  dynamic "logging" {
    for_each = var.logging == null ? [] : [1]
    content {
      target_bucket = var.logging["bucket_name"]
      target_prefix = var.logging["prefix"]
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

  dynamic "cors_rule" {
    for_each = var.cors_rule_inputs == null ? [] : var.cors_rule_inputs

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }

  dynamic "grant" {
    for_each = try(length(var.grants), 0) == 0 || try(length(var.acl), 0) > 0 ? [] : var.grants

    content {
      id          = grant.value.id
      type        = grant.value.type
      permissions = grant.value.permissions
      uri         = grant.value.uri
    }
  }

  dynamic "replication_configuration" {
    for_each = var.s3_replication_enabled ? [1] : []

    content {
      role = aws_iam_role.replication[0].arn

      dynamic "rules" {
        for_each = var.replication_rules == null ? [] : var.replication_rules

        content {
          id       = rules.value.id
          priority = try(rules.value.priority, 0)
          prefix   = try(rules.value.prefix, null)
          status   = try(rules.value.status, null)

          destination {
            bucket             = var.s3_replica_bucket_arn
            storage_class      = try(rules.value.destination.storage_class, "STANDARD")
            replica_kms_key_id = try(rules.value.destination.replica_kms_key_id, null)
            account_id         = try(rules.value.destination.account_id, null)

            dynamic "access_control_translation" {
              for_each = try(rules.value.destination.access_control_translation.owner, null) == null ? [] : [rules.value.destination.access_control_translation.owner]

              content {
                owner = access_control_translation.value
              }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = try(rules.value.source_selection_criteria.sse_kms_encrypted_objects.enabled, null) == null ? [] : [rules.value.source_selection_criteria.sse_kms_encrypted_objects.enabled]

            content {
              sse_kms_encrypted_objects {
                enabled = source_selection_criteria.value
              }
            }
          }

          dynamic "filter" {
            for_each = try(rules.value.filter, null) == null ? [] : [rules.value.filter]

            content {
              prefix = try(filter.value.prefix, null)
              tags   = try(filter.value.tags, {})
            }
          }
        }
      }
    }
  }

  dynamic "object_lock_configuration" {
    for_each = var.object_lock_configuration != null ? [1] : []
    content {
      object_lock_enabled = "Enabled"
      rule {
        default_retention {
          mode  = var.object_lock_configuration.mode
          days  = var.object_lock_configuration.days
          years = var.object_lock_configuration.years
        }
      }
    }
  }
}

module "s3_user" {
  source  = "cloudposse/iam-s3-user/aws"
  version = "0.15.2"

  enabled      = module.this.enabled && var.user_enabled ? true : false
  s3_actions   = var.allowed_bucket_actions
  s3_resources = ["${join("", aws_s3_bucket.default.*.arn)}/*", join("", aws_s3_bucket.default.*.arn)]

  context = module.this.context
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "bucket_policy" {
  count = module.this.enabled ? 1 : 0

  dynamic "statement" {
    for_each = var.allow_encrypted_uploads_only ? [1] : []

    content {
      sid       = "DenyIncorrectEncryptionHeader"
      effect    = "Deny"
      actions   = ["s3:PutObject"]
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}/*"]

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
  }

  dynamic "statement" {
    for_each = var.allow_encrypted_uploads_only ? [1] : []

    content {
      sid       = "DenyUnEncryptedObjectUploads"
      effect    = "Deny"
      actions   = ["s3:PutObject"]
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}/*"]

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

  dynamic "statement" {
    for_each = var.allow_ssl_requests_only ? [1] : []

    content {
      sid     = "ForceSSLOnlyAccess"
      effect  = "Deny"
      actions = ["s3:*"]
      resources = [
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}",
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}/*"
      ]

      principals {
        identifiers = ["*"]
        type        = "*"
      }

      condition {
        test     = "Bool"
        values   = ["false"]
        variable = "aws:SecureTransport"
      }
    }
  }
}

data "aws_iam_policy_document" "aggregated_policy" {
  count         = module.this.enabled ? 1 : 0
  source_json   = var.policy
  override_json = join("", data.aws_iam_policy_document.bucket_policy.*.json)
}

resource "aws_s3_bucket_policy" "default" {
  count      = module.this.enabled && (var.allow_ssl_requests_only || var.allow_encrypted_uploads_only || var.policy != "") ? 1 : 0
  bucket     = join("", aws_s3_bucket.default.*.id)
  policy     = join("", data.aws_iam_policy_document.aggregated_policy.*.json)
  depends_on = [aws_s3_bucket_public_access_block.default]
}

# Refer to the terraform documentation on s3_bucket_public_access_block at
# https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block.html
# for the nuances of the blocking options
resource "aws_s3_bucket_public_access_block" "default" {
  count  = module.this.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
