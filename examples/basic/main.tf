module "s3_bucket" {
  source             = "../../"
  enabled            = "true"
  name               = "s3-bucket"
  stage              = "test"
  namespace          = "example"
  versioning_enabled = "true"
  user_enabled       = "true"
}
