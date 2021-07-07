region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-lifecycle-test"

acl = "private"

lifecycle_rules = [
  {
    prefix  = null
    enabled = true
    tags    = { "temp" : "true" }

    enable_glacier_transition        = false
    enable_deeparchive_transition    = false
    enable_standard_ia_transition    = false
    enable_current_object_expiration = true

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

    enable_glacier_transition        = false
    enable_deeparchive_transition    = false
    enable_standard_ia_transition    = false
    enable_current_object_expiration = true

    abort_incomplete_multipart_upload_days         = 1
    noncurrent_version_glacier_transition_days     = 0
    noncurrent_version_deeparchive_transition_days = 0
    noncurrent_version_expiration_days             = 30

    standard_transition_days    = 0
    glacier_transition_days     = 0
    deeparchive_transition_days = 0
    expiration_days             = 30
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
