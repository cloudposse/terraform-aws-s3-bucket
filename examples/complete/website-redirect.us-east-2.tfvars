region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-test-redirect"

acl = "private"

force_destroy = true

user_enabled = false

versioning_enabled = false

allow_encrypted_uploads_only = false

bucket_key_enabled = true

website_redirect_all_requests_to = [{
  host_name = "www.example.com"
  protocol  = "https"
}]
