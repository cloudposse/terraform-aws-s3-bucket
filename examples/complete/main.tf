locals {
  replication_enabled = length(var.s3_replication_rules) > 0
  extra_rule = local.replication_enabled ? {
    id                 = "replication-test-explicit-bucket"
    status             = "Enabled"
    prefix             = "/extra"
    priority           = 5
    destination_bucket = module.s3_bucket_replication_target_extra[0].bucket_arn
  } : null
  s3_replication_rules = local.replication_enabled ? concat(var.s3_replication_rules, [local.extra_rule]) : null
}

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
  s3_replication_enabled       = local.replication_enabled
  s3_replica_bucket_arn        = join("", module.s3_bucket_replication_target.*.bucket_arn)
  s3_replication_rules         = local.s3_replication_rules

  context = module.this.context
}

module "s3_bucket_replication_target" {
  count = local.replication_enabled ? 1 : 0

  source = "../../"

  user_enabled                = true
  acl                         = "private"
  force_destroy               = true
  versioning_enabled          = true
  s3_replication_source_roles = [module.s3_bucket.replication_role_arn]

  attributes = ["target"]
  context    = module.this.context
}

module "s3_bucket_replication_target_extra" {
  count = local.replication_enabled ? 1 : 0

  source = "../../"

  user_enabled                = true
  acl                         = "private"
  force_destroy               = true
  versioning_enabled          = true
  s3_replication_source_roles = [module.s3_bucket.replication_role_arn]

  attributes = ["target", "extra"]
  context    = module.this.context
}
