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
  privileged_principal_arns    = var.privileged_principal_enabled ? {
    (local.principal_names[0]) = [""]
    (local.principal_names[1]) = ["a/", "b/"]
  } : {}
  privileged_principal_actions = var.privileged_principal_actions

  context = module.this.context
}