region = "us-west-1"

namespace = "eg"

stage = "test"

name = "s3-object-lock-test"

acl = ""

force_destroy = false

versioning_enabled = true

allowed_bucket_actions = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]

object_lock_configuration = {
  object_lock_enabled = "Enabled"

  rule = {
    default_retention = {
      mode = "GOVERNANCE"
      days = 366
    }
  }
}