region = "us-west-2"

namespace = "eg"

stage = "test"

name = "s3-replication-test"

acl = ""

replication_rules = [
  {
    id     = "foo-stuff"
    priority = 0
    prefix = "foo"
    status = "Enabled"
    destination = {
      storage_class = "STANDARD"
      #access_control_translation = {
      #  owner = null
      #}
      replica_kms_key_id = "arn:aws:kms:us-west-2:831653049478:key/06f9315a-414b-4c56-9421-44d9beb1deb4"
      #account_id         = null
    }
    filter = {
      prefix = "foo"
      tags   = {}
    }
    source_selection_criteria = {
      sse_kms_encrypted_objects = {
        enabled = true
      }
    }
  }
]

s3_replication_enabled = true

s3_replica_bucket_arn = "arn:aws:s3:::cloudposse-bucket-replication-test-foo"

force_destroy = true

versioning_enabled = true

allow_encrypted_uploads_only = true

allowed_bucket_actions = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
