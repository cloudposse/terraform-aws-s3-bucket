region = "us-east-2"

namespace = "eg"

stage = "test"

name = "s3-tiering-test"

acl = "private"

force_destroy = true

user_enabled = false

transfer_acceleration_enabled = false

intelligent_tiering_configuration = [
  {
    name = "archive-config"
    tiering = [
      {
        access_tier = "ARCHIVE_ACCESS"
        days        = 180
      },
      {
        access_tier = "DEEP_ARCHIVE_ACCESS"
        days        = 365
      },
    ]
  }
]
