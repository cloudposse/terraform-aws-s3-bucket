variable "acl" {
  type        = string
  default     = "private"
  description = <<-EOT
    The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply.
    Deprecated by AWS in favor of bucket policies.
    Automatically disabled if `s3_object_ownership` is set to "BucketOwnerEnforced".
    Defaults to "private" for backwards compatibility, but we recommend setting `s3_object_ownership` to "BucketOwnerEnforced" instead.
    EOT
}

variable "grants" {
  type = list(object({
    id          = string
    type        = string
    permissions = list(string)
    uri         = string
  }))
  default = []

  description = <<-EOT
    A list of policy grants for the bucket, taking a list of permissions.
    Conflicts with `acl`. Set `acl` to `null` to use this.
    Deprecated by AWS in favor of bucket policies.
    Automatically disabled if `s3_object_ownership` is set to "BucketOwnerEnforced".
    EOT
  nullable    = false
}

variable "source_policy_documents" {
  type        = list(string)
  default     = []
  description = <<-EOT
    List of IAM policy documents (in JSON) that are merged together into the exported document.
    Statements defined in source_policy_documents must have unique SIDs.
    Statement having SIDs that match policy SIDs generated by this module will override them.
    EOT
  nullable    = false
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = <<-EOT
    When `true`, permits a non-empty S3 bucket to be deleted by first deleting all objects in the bucket.
    THESE OBJECTS ARE NOT RECOVERABLE even if they were versioned and stored in Glacier.
    EOT
  nullable    = false
}

variable "versioning_enabled" {
  type        = bool
  default     = true
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket"
  nullable    = false
}

variable "logging" {
  type = list(object({
    bucket_name = string
    prefix      = string
  }))
  default     = []
  description = "Bucket access logging configuration. Empty list for no logging, list of 1 to enable logging."
  nullable    = false
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`"
  nullable    = false
}

variable "kms_master_key_arn" {
  type        = string
  default     = ""
  description = "The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`"
  nullable    = false
}

variable "user_enabled" {
  type        = bool
  default     = false
  description = "Set to `true` to create an IAM user with permission to access the bucket"
  nullable    = false
}

variable "user_permissions_boundary_arn" {
  type        = string
  default     = null
  description = "Permission boundary ARN for the IAM user created to access the bucket."
}

variable "access_key_enabled" {
  type        = bool
  default     = true
  description = "Set to `true` to create an IAM Access Key for the created IAM user"
  nullable    = false
}

variable "store_access_key_in_ssm" {
  type        = bool
  default     = false
  description = <<-EOT
    Set to `true` to store the created IAM user's access key in SSM Parameter Store,
    `false` to store them in Terraform state as outputs.
    Since Terraform state would contain the secrets in plaintext,
    use of SSM Parameter Store is recommended.
    EOT
  nullable    = false
}

variable "ssm_base_path" {
  type        = string
  description = "The base path for SSM parameters where created IAM user's access key is stored"
  default     = "/s3_user/"
  nullable    = false
}

variable "allowed_bucket_actions" {
  type        = list(string)
  default     = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  description = "List of actions the user is permitted to perform on the S3 bucket"
  nullable    = false
}

variable "allow_encrypted_uploads_only" {
  type        = bool
  default     = false
  description = "Set to `true` to prevent uploads of unencrypted objects to S3 bucket"
  nullable    = false
}

variable "allow_ssl_requests_only" {
  type        = bool
  default     = false
  description = "Set to `true` to require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests"
  nullable    = false
}

variable "minimum_tls_version" {
  type        = string
  default     = null
  description = "Set the minimum TLS version for in-transit traffic"
}

variable "lifecycle_configuration_rules" {
  type = list(object({
    enabled = optional(bool, true)
    id      = string

    abort_incomplete_multipart_upload_days = optional(number)

    # `filter_and` is the `and` configuration block inside the `filter` configuration.
    # This is the only place you should specify a prefix.
    filter_and = optional(object({
      object_size_greater_than = optional(number) # integer >= 0
      object_size_less_than    = optional(number) # integer >= 1
      prefix                   = optional(string)
      tags                     = optional(map(string), {})
    }))
    expiration = optional(object({
      date                         = optional(string) # string, RFC3339 time format, GMT
      days                         = optional(number) # integer > 0
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_expiration = optional(object({
      newer_noncurrent_versions = optional(number) # integer > 0
      noncurrent_days           = optional(number) # integer >= 0
    }))
    transition = optional(list(object({
      date          = optional(string) # string, RFC3339 time format, GMT
      days          = optional(number) # integer > 0
      storage_class = optional(string)
      # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    })), [])

    noncurrent_version_transition = optional(list(object({
      newer_noncurrent_versions = optional(number) # integer >= 0
      noncurrent_days           = optional(number) # integer >= 0
      storage_class             = optional(string)
      # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    })), [])
  }))
  default     = []
  description = "A list of lifecycle V2 rules"
  nullable    = false
}
# See lifecycle.tf for conversion of deprecated `lifecycle_rules` to `lifecycle_configuration_rules`


variable "cors_configuration" {
  type = list(object({
    id              = optional(string)
    allowed_headers = optional(list(string))
    allowed_methods = optional(list(string))
    allowed_origins = optional(list(string))
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  description = "Specifies the allowed headers, methods, origins and exposed headers when using CORS on this bucket"
  default     = []
  nullable    = false
}

variable "block_public_acls" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the blocking of new public access lists on the bucket"
  nullable    = false
}

variable "block_public_policy" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the blocking of new public policies on the bucket"
  nullable    = false
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the ignoring of public access lists on the bucket"
  nullable    = false
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the restricting of making the bucket public"
  nullable    = false
}

variable "s3_replication_enabled" {
  type        = bool
  default     = false
  description = "Set this to true and specify `s3_replication_rules` to enable replication. `versioning_enabled` must also be `true`."
  nullable    = false
}

variable "s3_replica_bucket_arn" {
  type        = string
  default     = ""
  description = <<-EOT
    A single S3 bucket ARN to use for all replication rules.
    Note: The destination bucket can be specified in the replication rule itself
    (which allows for multiple destinations), in which case it will take precedence over this variable.
    EOT
}

variable "s3_replication_rules" {
  type = list(object({
    id       = optional(string)
    priority = optional(number)
    prefix   = optional(string)
    status   = optional(string, "Enabled")
    # delete_marker_replication { status } had been flattened for convenience
    delete_marker_replication_status = optional(string, "Disabled")
    # Add the configuration as it appears in the resource, for consistency
    # this nested version takes precedence if both are provided.
    delete_marker_replication = optional(object({
      status = string
    }))

    # destination_bucket is specified here rather than inside the destination object because before optional
    # attributes, it made it easier to work with the Terraform type system and create a list of consistent type.
    # It is preserved for backward compatibility, but the nested version takes priority if both are provided.
    destination_bucket = optional(string) # destination bucket ARN, overrides s3_replica_bucket_arn

    destination = object({
      bucket        = optional(string) # destination bucket ARN, overrides s3_replica_bucket_arn
      storage_class = optional(string, "STANDARD")
      # replica_kms_key_id at this level is for backward compatibility, and is overridden by the one in `encryption_configuration`
      replica_kms_key_id = optional(string, "")
      encryption_configuration = optional(object({
        replica_kms_key_id = string
      }))
      access_control_translation = optional(object({
        owner = string
      }))
      # account_id is for backward compatibility, overridden by account
      account_id = optional(string)
      account    = optional(string)
      # For convenience, specifying either metrics or replication_time enables both
      metrics = optional(object({
        event_threshold = optional(object({
          minutes = optional(number, 15) # Currently 15 is the only valid number
        }), { minutes = 15 })
        status = optional(string, "Enabled")
      }), { status = "Disabled" })
      # To preserve backward compatibility, Replication Time Control (RTC) is automatically enabled
      # when metrics are enabled. To enable metrics without RTC, you must explicitly configure
      # replication_time.status = "Disabled".
      replication_time = optional(object({
        time = optional(object({
          minutes = optional(number, 15) # Currently 15 is the only valid number
        }), { minutes = 15 })
        status = optional(string)
      }))
    })

    source_selection_criteria = optional(object({
      replica_modifications = optional(object({
        status = string # Either Enabled or Disabled
      }))
      sse_kms_encrypted_objects = optional(object({
        status = optional(string)
      }))
    }))
    # filter.prefix overrides top level prefix
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string), {})
    }))
  }))
  default     = null
  description = "Specifies the replication rules for S3 bucket replication if enabled. You must also set s3_replication_enabled to true."
}
locals {
  # Deprecate `replication_rules` in favor of `s3_replication_rules` to keep all the replication related
  # inputs grouped under s3_replica[tion]
  s3_replication_rules = var.replication_rules == null ? var.s3_replication_rules : var.replication_rules
}

variable "s3_replication_source_roles" {
  type        = list(string)
  default     = []
  description = "Cross-account IAM Role ARNs that will be allowed to perform S3 replication to this bucket (for replication within the same AWS account, it's not necessary to adjust the bucket policy)."
  nullable    = false
}

variable "s3_replication_permissions_boundary_arn" {
  type        = string
  default     = null
  description = "Permissions boundary ARN for the created IAM replication role."
}

variable "bucket_name" {
  type        = string
  default     = null
  description = "Bucket name. If provided, the bucket will be created with this name instead of generating the name from the context"
}

variable "object_lock_configuration" {
  type = object({
    mode  = string # Valid values are GOVERNANCE and COMPLIANCE.
    days  = number
    years = number
  })
  default     = null
  description = "A configuration for S3 object locking. With S3 Object Lock, you can store objects using a `write once, read many` (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely."
}

variable "website_redirect_all_requests_to" {
  type = list(object({
    host_name = string
    protocol  = string
  }))
  description = "If provided, all website requests will be redirected to the specified host name and protocol"
  default     = []

  validation {
    condition     = length(var.website_redirect_all_requests_to) < 2
    error_message = "Only 1 website_redirect_all_requests_to is allowed."
  }
  nullable = false
}

variable "website_configuration" {
  type = list(object({
    index_document = string
    error_document = string
    routing_rules = list(object({
      condition = object({
        http_error_code_returned_equals = string
        key_prefix_equals               = string
      })
      redirect = object({
        host_name               = string
        http_redirect_code      = string
        protocol                = string
        replace_key_prefix_with = string
        replace_key_with        = string
      })
    }))
  }))
  description = "Specifies the static website hosting configuration object"
  default     = []

  validation {
    condition     = length(var.website_configuration) < 2
    error_message = "Only 1 website_configuration is allowed."
  }
  nullable = false
}

# Need input to be a list to fix https://github.com/cloudposse/terraform-aws-s3-bucket/issues/102
variable "privileged_principal_arns" {
  #  type        = map(list(string))
  #  default     = {}
  type    = list(map(list(string)))
  default = []

  description = <<-EOT
    List of maps. Each map has a key, an IAM Principal ARN, whose associated value is
    a list of S3 path prefixes to grant `privileged_principal_actions` permissions for that principal,
    in addition to the bucket itself, which is automatically included. Prefixes should not begin with '/'.
    EOT
  nullable    = false
}

variable "privileged_principal_actions" {
  type        = list(string)
  default     = []
  description = "List of actions to permit `privileged_principal_arns` to perform on bucket and bucket prefixes (see `privileged_principal_arns`)"
  nullable    = false
}

variable "source_ip_allow_list" {
  type        = list(string)
  default     = []
  description = "List of IP addresses to allow to perform all actions to the bucket"
  nullable    = false
}

variable "transfer_acceleration_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    Set this to `true` to enable S3 Transfer Acceleration for the bucket.
    Note: When this is set to `false` Terraform does not perform drift detection
    and will not disable Transfer Acceleration if it was enabled outside of Terraform.
    To disable it via Terraform, you must set this to `true` and then to `false`.
    Note: not all regions support Transfer Acceleration.
    EOT
  nullable    = false
}

variable "s3_object_ownership" {
  type        = string
  default     = "ObjectWriter"
  description = <<-EOT
    Specifies the S3 object ownership control.
    Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'.
    Defaults to "ObjectWriter" for backwards compatibility, but we recommend setting "BucketOwnerEnforced" instead.
    EOT
  nullable    = false
}

variable "bucket_key_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
  Set this to true to use Amazon S3 Bucket Keys for SSE-KMS, which may or may not reduce the number of AWS KMS requests.
  For more information, see: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
  EOT
  nullable    = false
}

variable "expected_bucket_owner" {
  type        = string
  default     = null
  description = <<-EOT
    Account ID of the expected bucket owner. 
    More information: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-owner-condition.html
  EOT
}

variable "event_notification_details" {
  type = object({
    enabled     = bool
    eventbridge = optional(bool, false)
    lambda_list = optional(list(object({
      lambda_function_arn = string
      events              = optional(list(string), ["s3:ObjectCreated:*"])
      filter_prefix       = optional(string)
      filter_suffix       = optional(string)
    })), [])

    queue_list = optional(list(object({
      queue_arn     = string
      events        = optional(list(string), ["s3:ObjectCreated:*"])
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])

    topic_list = optional(list(object({
      topic_arn     = string
      events        = optional(list(string), ["s3:ObjectCreated:*"])
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
  })
  description = "S3 event notification details"
  default = {
    enabled = false
  }
}

variable "s3_request_payment_configuration" {
  type = object({
    enabled               = bool
    expected_bucket_owner = optional(string)
    payer                 = string
  })
  description = "S3 request payment configuration"
  default = {
    enabled = false
    payer   = "BucketOwner"
  }
  validation {
    condition     = contains(["bucketowner", "requester"], lower(var.s3_request_payment_configuration.payer))
    error_message = "The s3 request payment config's payer must be either BucketOwner or Requester"
  }
}

variable "create_s3_directory_bucket" {
  description = "Control the creation of the S3 directory bucket. Set to true to create the bucket, false to skip."
  type        = bool
  default     = false
}

variable "availability_zone_id" {
  description = "The ID of the availability zone."
  type        = string
  default     = ""
}
