# Do not set "enabled", will be set by test framework
# enabled                      = true

region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-replication-test"

acl = "private"

force_destroy = true

versioning_enabled = true

allow_encrypted_uploads_only = true

allowed_bucket_actions = [
  "s3:PutObject",
  "s3:PutObjectAcl",
  "s3:GetObject",
  "s3:DeleteObject",
  "s3:ListBucket",
  "s3:ListBucketMultipartUploads",
  "s3:GetBucketLocation",
  "s3:AbortMultipartUpload",
]

s3_replication_enabled = true