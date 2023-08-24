region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-lifecycle-test"

acl = "private"

lifecycle_configuration_rules = [
  # Be sure to cover https://github.com/cloudposse/terraform-aws-s3-bucket/issues/137
  {
    abort_incomplete_multipart_upload_days = 1
    enabled                                = true
    expiration = {
      days                         = null
      expired_object_delete_marker = null
    }

    # test no filter
    filter_and = {}
    id         = "nofilter"
    noncurrent_version_expiration = {
      newer_noncurrent_versions = 2
      noncurrent_days           = 30
    }
    noncurrent_version_transition = []
    transition = [
      {
        days          = 7
        storage_class = "GLACIER"
      },
    ]

  },
  {
    abort_incomplete_multipart_upload_days = 1
    enabled                                = true
    expiration = {
      days                         = null
      expired_object_delete_marker = null
    }

    # test prefix only
    filter_and = {
      prefix = "prefix1"
    }
    id = "prefix1"
    noncurrent_version_expiration = {
      newer_noncurrent_versions = 2
      noncurrent_days           = 30
    }
    noncurrent_version_transition = []
    transition = [
      {
        days          = 7
        storage_class = "GLACIER"
      },
    ]

  },
  {
    abort_incomplete_multipart_upload_days = null
    enabled                                = true
    expiration = {
      days                         = 1461
      expired_object_delete_marker = false
    }
    # test prefix with other filter
    filter_and = {
      prefix                   = "prefix2"
      object_size_greater_than = 128 * 1024
    }
    id = "prefix2"
    noncurrent_version_expiration = {
      newer_noncurrent_versions = 2
      noncurrent_days           = 14
    }
    noncurrent_version_transition = []
    transition = [
      {
        days          = 366
        storage_class = "GLACIER"
      },
    ]
  },
  {
    abort_incomplete_multipart_upload_days = null
    enabled                                = true
    expiration = {
      days                         = 93
      expired_object_delete_marker = false
    }
    # test filter without prefix
    filter_and = {
      object_size_greater_than = 256 * 1024
    }
    id = "big"
    noncurrent_version_expiration = {
      newer_noncurrent_versions = 2
      noncurrent_days           = 14
    }
    noncurrent_version_transition = []
    transition = [
      {
        days          = 90
        storage_class = "GLACIER"
      },
    ]
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
