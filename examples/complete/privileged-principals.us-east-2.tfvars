enabled = true

region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-principals-test" # s3-privileged-principals-test will hit the name length limit

acl = "private"

force_destroy = true

allow_encrypted_uploads_only = true

privileged_principal_actions = [
  "s3:PutObject",
  "s3:PutObjectAcl",
  "s3:GetObject",
  "s3:DeleteObject",
  "s3:ListBucket",
  "s3:ListBucketMultipartUploads",
  "s3:GetBucketLocation",
  "s3:AbortMultipartUpload"
]

privileged_principal_enabled = true

versioning_enabled = false

user_enabled = false

transfer_acceleration_enabled = false
