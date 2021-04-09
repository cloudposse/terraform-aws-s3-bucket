provider "aws" {
  region = var.region
}

module "s3_bucket" {
  source = "../../"

  user_enabled                 = true
  acl                          = var.acl
  force_destroy                = var.force_destroy
  grants                       = var.grants
  lifecycle_rules              = var.lifecycle_rules
  versioning_enabled           = var.versioning_enabled
  allow_encrypted_uploads_only = var.allow_encrypted_uploads_only
  allowed_bucket_actions       = var.allowed_bucket_actions
  bucket_name                  = var.bucket_name
  object_lock_configuration    = var.object_lock_configuration

  context = module.this.context
}
