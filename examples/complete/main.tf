provider "aws" {
  region = var.region
}

module "s3_bucket" {
  source = "../../"

  enabled                      = true
  user_enabled                 = true
  namespace                    = var.namespace
  stage                        = var.stage
  name                         = var.name
  attributes                   = var.attributes
  acl                          = var.acl
  force_destroy                = var.force_destroy
  grants                       = var.grants
  versioning_enabled           = var.versioning_enabled
  allow_encrypted_uploads_only = var.allow_encrypted_uploads_only
  allowed_bucket_actions       = var.allowed_bucket_actions
}
