region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-test-website"

acl = "private"

force_destroy = true

user_enabled = false

versioning_enabled = false

allow_encrypted_uploads_only = false

bucket_key_enabled = true

website_configuration = [
  {
    index_document = "index.html"
    error_document = null
    routing_rules = [
      {
        condition = {
          http_error_code_returned_equals = "404"
          key_prefix_equals               = "docs/"
        }
        redirect = {
          host_name               = null
          http_redirect_code      = "301"
          protocol                = "https"
          replace_key_prefix_with = "documents/"
          replace_key_with        = null
        }
      },
      {
        condition = {
          http_error_code_returned_equals = null
          key_prefix_equals               = null
        }
        redirect = {
          host_name               = null
          http_redirect_code      = "302"
          protocol                = "https"
          replace_key_prefix_with = "maintenance/"
          replace_key_with        = null
        }
      }
    ]
  }
]

cors_configuration = [
  {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://s3-website-test.testing.cloudposse.co"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  },
  {
    allowed_headers = null
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = null
    max_age_seconds = null
  }
]
