provider "aws" {
  region = var.region
}

module "s3_bucket" {
  source = "../../"

  enabled                      = true
  user_enabled                 = true
  region                       = var.region
  namespace                    = var.namespace
  stage                        = var.stage
  name                         = var.name
  acl                          = var.acl
  force_destroy                = var.force_destroy
  versioning_enabled           = var.versioning_enabled
  allow_encrypted_uploads_only = var.allow_encrypted_uploads_only
  allowed_bucket_actions       = var.allowed_bucket_actions
}
