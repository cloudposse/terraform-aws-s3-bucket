enabled = true

region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-test"

acl = "private"

force_destroy = true

user_enabled = true

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

policy = [
  <<-EOT
  {
    "Version": "2012-10-17",
    "Id": "123",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:*",
        "Resource": "*",
        "Condition": { "Null": { "aws:MultiFactorAuthAge": true }}
      }
    ]
  }
  EOT
]