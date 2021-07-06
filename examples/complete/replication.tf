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
