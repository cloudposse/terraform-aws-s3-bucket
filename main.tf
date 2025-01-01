locals {
  enabled               = module.this.enabled
  partition             = join("", data.aws_partition.current[*].partition)
  directory_bucket_name = var.create_s3_directory_bucket ? "${local.bucket_name}-${var.availability_zone_id}" : ""

  object_lock_enabled           = local.enabled && var.object_lock_configuration != null
  replication_enabled           = local.enabled && var.s3_replication_enabled
  versioning_enabled            = local.enabled && var.versioning_enabled
  transfer_acceleration_enabled = local.enabled && var.transfer_acceleration_enabled

  # Remember, everything has to work with enabled == false,
  # so we cannot use coalesce() because it errors if all its arguments are empty,
  # and we cannot use one() because it returns null, which does not work in templates and lists.
  bucket_name = var.bucket_name != null && var.bucket_name != "" ? var.bucket_name : module.this.id
  bucket_id   = join("", aws_s3_bucket.default[*].id)
  bucket_arn  = "arn:${local.partition}:s3:::${local.bucket_id}"

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
  count         = local.enabled ? 1 : 0
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  object_lock_enabled = local.object_lock_enabled

  tags = module.this.tags
}

resource "aws_s3_bucket_accelerate_configuration" "default" {
  count = local.transfer_acceleration_enabled ? 1 : 0

  bucket = local.bucket_id
  status = "Enabled"
}

# Ensure the resource exists to track drift, even if the feature is disabled
resource "aws_s3_bucket_versioning" "default" {
  count = local.enabled ? 1 : 0

  bucket                = local.bucket_id
  expected_bucket_owner = var.expected_bucket_owner

  versioning_configuration {
    status = local.versioning_enabled ? "Enabled" : "Suspended"
  }
}

moved {
  from = aws_s3_bucket_logging.default[0]
  to   = aws_s3_bucket_logging.default["enabled"]
}

resource "aws_s3_bucket_logging" "default" {
  for_each = toset(local.enabled && length(var.logging) > 0 ? ["enabled"] : [])

  bucket                = local.bucket_id
  expected_bucket_owner = var.expected_bucket_owner

  target_bucket = var.logging[0]["bucket_name"]
  target_prefix = var.logging[0]["prefix"]
}

# https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count = local.enabled ? 1 : 0

  bucket                = local.bucket_id
  expected_bucket_owner = var.expected_bucket_owner

  rule {
    bucket_key_enabled = var.bucket_key_enabled

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_master_key_arn
    }
  }
}

resource "aws_s3_bucket_website_configuration" "default" {
  count = local.enabled && (try(length(var.website_configuration), 0) > 0) ? 1 : 0

  bucket = local.bucket_id

  dynamic "index_document" {
    for_each = try(length(var.website_configuration[0].index_document), 0) > 0 ? [true] : []
    content {
      suffix = var.website_configuration[0].index_document
    }
  }

  dynamic "error_document" {
    for_each = try(length(var.website_configuration[0].error_document), 0) > 0 ? [true] : []
    content {
      key = var.website_configuration[0].error_document
    }
  }

  dynamic "routing_rule" {
    for_each = try(length(var.website_configuration[0].routing_rules), 0) > 0 ? var.website_configuration[0].routing_rules : []
    content {
      dynamic "condition" {
        // Test for null or empty strings
        for_each = try(length(routing_rule.value.condition.http_error_code_returned_equals), 0) + try(length(routing_rule.value.condition.key_prefix_equals), 0) > 0 ? [true] : []
        content {
          http_error_code_returned_equals = routing_rule.value.condition.http_error_code_returned_equals
          key_prefix_equals               = routing_rule.value.condition.key_prefix_equals
        }
      }

      redirect {
        host_name               = routing_rule.value.redirect.host_name
        http_redirect_code      = routing_rule.value.redirect.http_redirect_code
        protocol                = routing_rule.value.redirect.protocol
        replace_key_prefix_with = routing_rule.value.redirect.replace_key_prefix_with
        replace_key_with        = routing_rule.value.redirect.replace_key_with
      }
    }
  }
}

// The "redirect_all_requests_to" block is mutually exclusive with all other blocks,
// any trying to switch from one to the other will cause a conflict.
resource "aws_s3_bucket_website_configuration" "redirect" {
  count = local.enabled && (try(length(var.website_redirect_all_requests_to), 0) > 0) ? 1 : 0

  bucket = local.bucket_id

  redirect_all_requests_to {
    host_name = var.website_redirect_all_requests_to[0].host_name
    protocol  = var.website_redirect_all_requests_to[0].protocol
  }
}

resource "aws_s3_bucket_cors_configuration" "default" {
  count = local.enabled && try(length(var.cors_configuration), 0) > 0 ? 1 : 0

  bucket = local.bucket_id

  dynamic "cors_rule" {
    for_each = var.cors_configuration

    content {
      id              = cors_rule.value.id
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_acl" "default" {
  count = local.enabled && var.s3_object_ownership != "BucketOwnerEnforced" ? 1 : 0

  bucket                = local.bucket_id
  expected_bucket_owner = var.expected_bucket_owner

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
        id = one(data.aws_canonical_user_id.default[*].id)
      }
    }
  }
  depends_on = [aws_s3_bucket_ownership_controls.default]
}

resource "aws_s3_bucket_replication_configuration" "default" {
  count = local.replication_enabled ? 1 : 0

  bucket = local.bucket_id
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
        status = try(rule.value.delete_marker_replication.status, try(rule.value.delete_marker_replication_status, "Disabled"))
      }

      destination {
        # Prefer newer system of specifying bucket in rule, but maintain backward compatibility with
        # s3_replica_bucket_arn to specify single destination for all rules
        bucket        = coalesce(rule.value.destination.bucket, rule.value.destination_bucket, var.s3_replica_bucket_arn)
        storage_class = rule.value.destination.storage_class

        dynamic "encryption_configuration" {
          for_each = try(
            [rule.value.destination.encryption_configuration.replica_kms_key_id],
            [compact(rule.value.destination.replica_kms_key_id)],
            []
          )

          content {
            replica_kms_key_id = encryption_configuration.value
          }
        }

        account = try(coalesce(rule.value.destination.account, rule.value.destination.account_id), null)

        dynamic "metrics" {
          # Metrics are required if Replication Time Control is enabled, so automatically enable them
          for_each = (
            try(rule.value.destination.metrics.status, "") == "Enabled" ||
            try(rule.value.destination.replication_time.status, "") == "Enabled"
          ) ? [1] : []

          content {
            status = "Enabled"
            event_threshold {
              # Minutes can only have 15 as a valid value, but we allow it to be configured anyway
              minutes = coalesce(try(rule.value.destination.metrics.event_threshold.minutes, null), 15)
            }
          }
        }

        # https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-walkthrough-5.html
        dynamic "replication_time" {
          for_each = (
            # Preserving the old behavior of this module: if metrics are enabled,
            # replication is automatically enabled unless explicitly disabled.
            (try(rule.value.destination.metrics.status, "") == "Enabled" && !(try(rule.value.destination.replication_time.status, "") == "Disabled")) ||
            try(rule.value.destination.replication_time.status, "") == "Enabled"
          ) ? [1] : []

          content {
            status = "Enabled"
            time {
              # Minutes can only have 15 as a valid value, but we allow it to be configured anyway
              minutes = coalesce(try(rule.value.destination.replication_time.time.minutes, null), 15)
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
        for_each = try(rule.value.source_selection_criteria, null) == null ? [] : [rule.value.source_selection_criteria]

        content {
          replica_modifications {
            status = try(source_selection_criteria.value.replica_modifications.status, "Disabled")
          }
          sse_kms_encrypted_objects {
            status = try(source_selection_criteria.value.sse_kms_encrypted_objects.status, "Disabled")
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
  count = local.object_lock_enabled ? 1 : 0

  bucket = local.bucket_id

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
  version = "1.2.0"

  enabled      = local.enabled && var.user_enabled
  s3_actions   = var.allowed_bucket_actions
  s3_resources = ["${join("", aws_s3_bucket.default[*].arn)}/*", one(aws_s3_bucket.default[*].arn)]

  create_iam_access_key = var.access_key_enabled
  ssm_enabled           = var.store_access_key_in_ssm
  ssm_base_path         = var.ssm_base_path
  permissions_boundary  = var.user_permissions_boundary_arn

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
    for_each = var.minimum_tls_version != null ? toset([var.minimum_tls_version]) : toset([])

    content {
      sid       = "EnforceTLSVersion"
      effect    = "Deny"
      actions   = ["s3:*"]
      resources = [local.bucket_arn, "${local.bucket_arn}/*"]

      principals {
        identifiers = ["*"]
        type        = "*"
      }

      condition {
        test     = "NumericLessThan"
        values   = [statement.value]
        variable = "s3:TlsVersion"
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
        "arn:${local.partition}:s3:::${local.bucket_id}",
        formatlist("arn:${local.partition}:s3:::${local.bucket_id}/%s*", values(statement.value)[0]),
      ]))
      principals {
        type        = "AWS"
        identifiers = [keys(statement.value)[0]]
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.source_ip_allow_list) > 0 ? [1] : []

    content {
      sid       = "AllowIPPrincipals"
      effect    = "Deny"
      actions   = ["s3:*"]
      resources = [local.bucket_arn, "${local.bucket_arn}/*"]
      principals {
        identifiers = ["*"]
        type        = "*"
      }
      condition {
        test     = "NotIpAddress"
        variable = "aws:SourceIp"
        values   = var.source_ip_allow_list
      }
    }

  }

}

data "aws_iam_policy_document" "aggregated_policy" {
  count = local.enabled ? 1 : 0

  source_policy_documents   = [one(data.aws_iam_policy_document.bucket_policy[*].json)]
  override_policy_documents = var.source_policy_documents
}

resource "aws_s3_bucket_policy" "default" {
  count = local.enabled && (
    var.allow_ssl_requests_only ||
    var.allow_encrypted_uploads_only ||
    length(var.s3_replication_source_roles) > 0 ||
    length(var.privileged_principal_arns) > 0 ||
    length(var.source_policy_documents) > 0
  ) ? 1 : 0

  bucket     = local.bucket_id
  policy     = one(data.aws_iam_policy_document.aggregated_policy[*].json)
  depends_on = [aws_s3_bucket_public_access_block.default]
}

# Refer to the terraform documentation on s3_bucket_public_access_block at
# https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block.html
# for the nuances of the blocking options
resource "aws_s3_bucket_public_access_block" "default" {
  count = module.this.enabled ? 1 : 0

  bucket = local.bucket_id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Per https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html
resource "aws_s3_bucket_ownership_controls" "default" {
  count = local.enabled ? 1 : 0

  bucket = local.bucket_id

  rule {
    object_ownership = var.s3_object_ownership
  }
  depends_on = [time_sleep.wait_for_aws_s3_bucket_settings]
}

# Workaround S3 eventual consistency for settings objects
resource "time_sleep" "wait_for_aws_s3_bucket_settings" {
  count = local.enabled ? 1 : 0

  depends_on       = [aws_s3_bucket_public_access_block.default, aws_s3_bucket_policy.default]
  create_duration  = "30s"
  destroy_duration = "30s"
}

# S3 event Bucket Notifications 
resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.event_notification_details.enabled ? 1 : 0
  bucket = local.bucket_id

  eventbridge = var.event_notification_details.eventbridge

  dynamic "lambda_function" {
    for_each = var.event_notification_details.lambda_list
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = var.event_notification_details.queue_list
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }

  dynamic "topic" {
    for_each = var.event_notification_details.topic_list
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }
}

# Directory Bucket 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_directory_bucket
resource "aws_s3_directory_bucket" "default" {
  count         = var.create_s3_directory_bucket ? 1 : 0
  bucket        = local.directory_bucket_name
  force_destroy = var.force_destroy

  location {
    name = var.availability_zone_id
  }
}

resource "aws_s3_bucket_request_payment_configuration" "default" {
  count = local.enabled && var.s3_request_payment_configuration.enabled ? 1 : 0

  bucket                = local.bucket_id
  expected_bucket_owner = var.s3_request_payment_configuration.expected_bucket_owner
  payer                 = lower(var.s3_request_payment_configuration.payer) == "requester" ? "Requester" : "BucketOwner"
}
