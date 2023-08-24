provider "aws" {
  region = var.region
}

provider "awsutils" {
  region = var.region
}

module "s3_bucket" {
  source = "../../"

  user_enabled                  = var.user_enabled
  acl                           = var.acl
  force_destroy                 = var.force_destroy
  grants                        = var.grants
  lifecycle_rules               = var.lifecycle_rules
  lifecycle_configuration_rules = var.lifecycle_configuration_rules
  versioning_enabled            = var.versioning_enabled
  allow_encrypted_uploads_only  = var.allow_encrypted_uploads_only
  allowed_bucket_actions        = var.allowed_bucket_actions
  bucket_name                   = var.bucket_name
  object_lock_configuration     = var.object_lock_configuration
  s3_replication_enabled        = local.s3_replication_enabled
  s3_replica_bucket_arn         = join("", module.s3_bucket_replication_target[*].bucket_arn)
  s3_replication_rules          = local.s3_replication_rules
  privileged_principal_actions  = var.privileged_principal_actions
  privileged_principal_arns     = local.privileged_principal_arns
  transfer_acceleration_enabled = var.transfer_acceleration_enabled
  bucket_key_enabled            = var.bucket_key_enabled
  source_policy_documents       = var.source_policy_documents
  sse_algorithm                 = var.sse_algorithm
  kms_master_key_arn            = var.kms_master_key_arn
  block_public_acls             = var.block_public_acls
  block_public_policy           = var.block_public_policy
  ignore_public_acls            = var.ignore_public_acls
  restrict_public_buckets       = var.restrict_public_buckets

  access_key_enabled      = var.access_key_enabled
  store_access_key_in_ssm = var.store_access_key_in_ssm
  ssm_base_path           = "/${module.this.id}"

  website_configuration            = var.website_configuration
  cors_configuration               = var.cors_configuration
  website_redirect_all_requests_to = var.website_redirect_all_requests_to

  context = module.this.context
}
