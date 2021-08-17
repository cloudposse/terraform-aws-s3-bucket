region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-object-policy-test"

acl = "private"

force_destroy = false

versioning_enabled = false

policy = <<-EOT
{
  "Version" = "2012-10-17",
  "Id"      = "MYBUCKETPOLICY",
  "Statement" = [
    {
      "Sid" = "testbucket-name-bucket_policy",
      "Effect" = "Allow",
      "Action" = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:GetBucketLocation",
        "s3:AbortMultipartUpload"
      ],
      "Resource" = [
        "arn:aws:s3:::testbucket-name",
        "arn:aws:s3:::testbucket-name/*"
      ],
      "Principal" = {
        "AWS" : ["somerandom-principle-arn"]
      }
    },
  ] 
}
EOT
