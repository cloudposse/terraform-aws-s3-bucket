region = "us-west-1"

namespace = "eg"

stage = "test"

name = "s3-grants-test"

acl = null

grants = [
  {
    id          = "123456789"
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    uri         = null
  },
  {
    id          = "987654321"
    type        = "Group"
    permissions = ["READ", "WRITE"]
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  },
]

force_destroy = true

versioning_enabled = false

allow_encrypted_uploads_only = true

allowed_bucket_actions = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
