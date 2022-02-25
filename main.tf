locals {
  enabled   = module.this.enabled
  partition = join("", data.aws_partition.current.*.partition)

  replication_enabled           = local.enabled && var.s3_replication_enabled
  versioning_enabled            = local.enabled && var.versioning_enabled
  transfer_acceleration_enabled = local.enabled && var.transfer_acceleration_enabled

  bucket_name = var.bucket_name != null && var.bucket_name != "" ? var.bucket_name : module.this.id
  bucket_arn  = "arn:${local.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}"

  public_access_block_enabled = var.block_public_acls || var.block_public_policy || var.ignore_public_acls || var.restrict_public_buckets

  acl_grants = var.grants == null ? [] : flatten(
    [
      for g in var.grants : [
        for p in g.permissions : {
          id         = g.id
          type       = g.type
          permission = p
          uri        = g.uri
        }
      ]
  ])
}

data "aws_partition" "current" { count = local.enabled ? 1 : 0 }
data "aws_canonical_user_id" "default" { count = local.enabled ? 1 : 0 }

resource "aws_s3_bucket" "default" {
  #bridgecrew:skip=BC_AWS_S3_13:Skipping `Enable S3 Bucket Logging` because we do not have good defaults
  #bridgecrew:skip=CKV_AWS_52:Skipping `Ensure S3 bucket has MFA delete enabled` due to issue in terraform (https://github.com/hashicorp/terraform-provider-aws/issues/629).
  #bridgecrew:skip=BC_AWS_S3_16:Skipping `Ensure S3 bucket versioning is enabled` because dynamic blocks are not supported by checkov
  #bridgecrew:skip=BC_AWS_S3_14:Skipping `Ensure all data stored in the S3 bucket is securely encrypted at rest` because variables are not understood
  #bridgecrew:skip=BC_AWS_GENERAL_56:Skipping `Ensure that S3 buckets are encrypted with KMS by default` because we do not have good defaults
  #bridgecrew:skip=BC_AWS_GENERAL_72:We do not agree that cross-region replication must be enabled
  count         = local.enabled ? 1 : 0
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  dynamic "object_lock_configuration" {
    for_each = var.object_lock_configuration != null ? [1] : []

    content {
      object_lock_enabled = "Enabled"
    }
  }

  tags = module.this.tags
}

resource "aws_s3_bucket_accelerate_configuration" "default" {
  count  = local.transfer_acceleration_enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)
  status = "Enabled"
}

resource "aws_s3_bucket_versioning" "default" {
  count = local.versioning_enabled ? 1 : 0

  bucket = join("", aws_s3_bucket.default.*.id)

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "default" {
  count  = local.enabled && var.logging != null ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  target_bucket = var.logging["bucket_name"]
  target_prefix = var.logging["prefix"]
}

# https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count  = local.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  rule {
    bucket_key_enabled = var.bucket_key_enabled

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_master_key_arn
    }
  }
}

resource "aws_s3_bucket_website_configuration" "default" {
  for_each = local.enabled && var.website_inputs != null ? toset(var.website_inputs) : toset([])
  bucket   = join("", aws_s3_bucket.default.*.id)

  index_document {
    suffix = each.value.index_document
  }

  error_document {
    key = each.value.error_document
  }

  redirect_all_requests_to {
    host_name = each.value.redirect_all_requests_to
    protocol  = each.value.protocol
  }

  dynamic "routing_rule" {
    for_each = length(jsondecode(each.value.routing_rules)) > 0 ? jsondecode(each.value.routing_rules) : []
    content {
      dynamic "condition" {
        for_each = routing_rule.value["Condition"]

        content {
          key_prefix_equals = lookup(condition.value, "KeyPrefixEquals")
        }
      }

      dynamic "redirect" {
        for_each = routing_rule.value["Redirect"]
        content {
          replace_key_prefix_with = lookup(redirect.value, "ReplaceKeyPrefixWith")
        }
      }
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "default" {
  count = local.enabled && var.cors_rule_inputs != null ? 1 : 0

  bucket = join("", aws_s3_bucket.default.*.id)

  dynamic "cors_rule" {
    for_each = var.cors_rule_inputs

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_acl" "default" {
  count  = local.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  # Conflicts with access_control_policy so this is enabled if no grants
  acl = try(length(local.acl_grants), 0) == 0 ? var.acl : null

  dynamic "access_control_policy" {
    for_each = try(length(local.acl_grants), 0) == 0 || try(length(var.acl), 0) > 0 ? [] : [1]

    content {
      dynamic "grant" {
        for_each = local.acl_grants

        content {
          grantee {
            id   = grant.value.id
            type = grant.value.type
            uri  = grant.value.uri
          }
          permission = grant.value.permission
        }
      }

      owner {
        id = join("", data.aws_canonical_user_id.default.*.id)
      }
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "default" {
  count = local.replication_enabled ? 1 : 0

  bucket = join("", aws_s3_bucket.default.*.id)
  role   = aws_iam_role.replication[0].arn

  dynamic "rule" {
    for_each = local.s3_replication_rules == null ? [] : local.s3_replication_rules

    content {
      id       = rule.value.id
      priority = try(rule.value.priority, 0)

      # `prefix` at this level is a V1 feature, replaced in V2 with the filter block.
      # `prefix` conflicts with `filter`, and for multiple destinations, a filter block
      # is required even if it empty, so we always implement `prefix` as a filter.
      # OBSOLETE: prefix   = try(rule.value.prefix, null)
      status = try(rule.value.status, null)

      # This is only relevant when "filter" is used
      delete_marker_replication {
        status = try(rule.value.delete_marker_replication_status, "Disabled")
      }

      destination {
        # Prefer newer system of specifying bucket in rule, but maintain backward compatibility with
        # s3_replica_bucket_arn to specify single destination for all rules
        bucket        = try(length(rule.value.destination_bucket), 0) > 0 ? rule.value.destination_bucket : var.s3_replica_bucket_arn
        storage_class = try(rule.value.destination.storage_class, "STANDARD")

        dynamic "encryption_configuration" {
          for_each = try(rule.value.destination.replica_kms_key_id, null) != null ? [1] : []

          content {
            replica_kms_key_id = try(rule.value.destination.replica_kms_key_id, null)
          }
        }

        account = try(rule.value.destination.account_id, null)

        # https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-walkthrough-5.html
        dynamic "metrics" {
          for_each = try(rule.value.destination.metrics.status, "") == "Enabled" ? [1] : []

          content {
            status = "Enabled"
            event_threshold {
              # Minutes can only have 15 as a valid value.
              minutes = 15
            }
          }
        }

        # This block is required when replication metrics are enabled.
        dynamic "replication_time" {
          for_each = try(rule.value.destination.metrics.status, "") == "Enabled" ? [1] : []

          content {
            status = "Enabled"
            time {
              # Minutes can only have 15 as a valid value.
              minutes = 15
            }
          }
        }

        dynamic "access_control_translation" {
          for_each = try(rule.value.destination.access_control_translation.owner, null) == null ? [] : [rule.value.destination.access_control_translation.owner]

          content {
            owner = access_control_translation.value
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = try(rule.value.source_selection_criteria.sse_kms_encrypted_objects.enabled, null) == null ? [] : [rule.value.source_selection_criteria.sse_kms_encrypted_objects.enabled]

        content {
          sse_kms_encrypted_objects {
            status = source_selection_criteria.value
          }
        }
      }

      # Replication to multiple destination buckets requires that priority is specified in the rules object.
      # If the corresponding rule requires no filter, an empty configuration block filter {} must be specified.
      # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
      dynamic "filter" {
        for_each = try(rule.value.filter, null) == null ? [{ prefix = null, tags = {} }] : [rule.value.filter]

        content {
          prefix = try(filter.value.prefix, try(rule.value.prefix, null))
          dynamic "tag" {
            for_each = try(filter.value.tags, {})

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }
    }
  }

  depends_on = [
    # versioning must be set before replication
    aws_s3_bucket_versioning.default
  ]
}

resource "aws_s3_bucket_object_lock_configuration" "default" {
  count = local.enabled && var.object_lock_configuration != null ? 1 : 0

  bucket = join("", aws_s3_bucket.default.*.id)

  object_lock_enabled = "Enabled"

  rule {
    default_retention {
      mode  = var.object_lock_configuration.mode
      days  = var.object_lock_configuration.days
      years = var.object_lock_configuration.years
    }
  }
}

module "s3_user" {
  source  = "cloudposse/iam-s3-user/aws"
  version = "0.15.7"

  enabled      = local.enabled && var.user_enabled
  s3_actions   = var.allowed_bucket_actions
  s3_resources = ["${join("", aws_s3_bucket.default.*.arn)}/*", join("", aws_s3_bucket.default.*.arn)]

  context = module.this.context
}

data "aws_iam_policy_document" "bucket_policy" {
  count = local.enabled ? 1 : 0

  dynamic "statement" {
    for_each = var.allow_encrypted_uploads_only ? [1] : []

    content {
      sid       = "DenyIncorrectEncryptionHeader"
      effect    = "Deny"
      actions   = ["s3:PutObject"]
      resources = ["${local.bucket_arn}/*"]

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
      resources = ["${local.bucket_arn}/*"]

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
      sid       = "ForceSSLOnlyAccess"
      effect    = "Deny"
      actions   = ["s3:*"]
      resources = [local.bucket_arn, "${local.bucket_arn}/*"]

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

  dynamic "statement" {
    for_each = length(var.s3_replication_source_roles) > 0 ? [1] : []

    content {
      sid = "CrossAccountReplicationObjects"
      actions = [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags",
        "s3:GetObjectVersionTagging",
        "s3:ObjectOwnerOverrideToBucketOwner"
      ]
      resources = ["${local.bucket_arn}/*"]
      principals {
        type        = "AWS"
        identifiers = var.s3_replication_source_roles
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.s3_replication_source_roles) > 0 ? [1] : []

    content {
      sid       = "CrossAccountReplicationBucket"
      actions   = ["s3:List*", "s3:GetBucketVersioning", "s3:PutBucketVersioning"]
      resources = [local.bucket_arn]
      principals {
        type        = "AWS"
        identifiers = var.s3_replication_source_roles
      }
    }
  }

  dynamic "statement" {
    for_each = var.privileged_principal_arns

    content {
      sid     = "AllowPrivilegedPrincipal[${statement.key}]" # add indices to Sid
      actions = var.privileged_principal_actions
      resources = distinct(flatten([
        "arn:${local.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}",
        formatlist("arn:${local.partition}:s3:::${join("", aws_s3_bucket.default.*.id)}/%s*", values(statement.value)[0]),
      ]))
      principals {
        type        = "AWS"
        identifiers = [keys(statement.value)[0]]
      }
    }
  }
}

data "aws_iam_policy_document" "aggregated_policy" {
  count = local.enabled ? 1 : 0

  source_policy_documents   = data.aws_iam_policy_document.bucket_policy.*.json
  override_policy_documents = local.source_policy_documents
}

resource "aws_s3_bucket_policy" "default" {
  count      = local.enabled && (var.allow_ssl_requests_only || var.allow_encrypted_uploads_only || length(var.s3_replication_source_roles) > 0 || length(var.privileged_principal_arns) > 0 || var.policy != "") ? 1 : 0
  bucket     = join("", aws_s3_bucket.default.*.id)
  policy     = join("", data.aws_iam_policy_document.aggregated_policy.*.json)
  depends_on = [aws_s3_bucket_public_access_block.default]
}

# Refer to the terraform documentation on s3_bucket_public_access_block at
# https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block.html
# for the nuances of the blocking options
resource "aws_s3_bucket_public_access_block" "default" {
  count  = module.this.enabled && local.public_access_block_enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Per https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html
resource "aws_s3_bucket_ownership_controls" "default" {
  count  = local.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  rule {
    object_ownership = var.s3_object_ownership
  }
  depends_on = [time_sleep.wait_for_aws_s3_bucket_settings]
}

# Workaround S3 eventual consistency for settings objects
resource "time_sleep" "wait_for_aws_s3_bucket_settings" {
  count            = local.enabled ? 1 : 0
  depends_on       = [aws_s3_bucket_public_access_block.default, aws_s3_bucket_policy.default]
  create_duration  = "30s"
  destroy_duration = "30s"
}
