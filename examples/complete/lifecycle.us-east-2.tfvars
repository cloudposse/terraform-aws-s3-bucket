region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-lifecycle-test"

acl = "private"

lifecycle_configuration_rules = [
  {
    enabled = true # bool
    id      = "v2rule"

    abort_incomplete_multipart_upload_days = 1 # number

    filter_and = null
    expiration = {
      days = 120 # integer > 0
    }
    noncurrent_version_expiration = {
      newer_noncurrent_versions = 3  # integer > 0
      noncurrent_days           = 60 # integer >= 0
    }
    transition = [{
      days          = 30            # integer >= 0
      storage_class = "STANDARD_IA" # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
      },
      {
        days          = 60           # integer >= 0
        storage_class = "ONEZONE_IA" # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    }]
    noncurrent_version_transition = [{
      newer_noncurrent_versions = 3            # integer >= 0
      noncurrent_days           = 30           # integer >= 0
      storage_class             = "ONEZONE_IA" # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    }]
  }
]

lifecycle_rules = [
  {
    prefix  = null
    enabled = true
    tags    = { "temp" : "true" }

    enable_glacier_transition            = false
    enable_deeparchive_transition        = false
    enable_standard_ia_transition        = false
    enable_current_object_expiration     = true
    enable_noncurrent_version_expiration = true

    abort_incomplete_multipart_upload_days         = null
    noncurrent_version_glacier_transition_days     = 0
    noncurrent_version_deeparchive_transition_days = 0
    noncurrent_version_expiration_days             = 30

    standard_transition_days    = 0
    glacier_transition_days     = 0
    deeparchive_transition_days = 0
    expiration_days             = 1
  },
  {
    prefix  = null
    enabled = true
    tags    = {}

    enable_glacier_transition            = false
    enable_deeparchive_transition        = true
    enable_standard_ia_transition        = false
    enable_current_object_expiration     = true
    enable_noncurrent_version_expiration = true

    abort_incomplete_multipart_upload_days         = 1
    noncurrent_version_glacier_transition_days     = 0
    noncurrent_version_deeparchive_transition_days = 120
    noncurrent_version_expiration_days             = 366

    standard_transition_days    = 0
    glacier_transition_days     = 0
    deeparchive_transition_days = 366
    expiration_days             = 366 * 4
  }
]

force_destroy = true

versioning_enabled = false

allow_encrypted_uploads_only = true

allowed_bucket_actions = [
  "s3:PutObject",
  "s3:PutObjectAcl",
  "s3:GetObject",
  "s3:DeleteObject",
  "s3:ListBucket",
  "s3:ListBucketMultipartUploads",
  "s3:GetBucketLocation",
  "s3:AbortMultipartUpload"
]
