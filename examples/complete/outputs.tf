output "bucket_domain_name" {
  value       = module.s3_bucket.bucket_domain_name
  description = "FQDN of bucket"
}

output "bucket_website_domain" {
  value       = module.s3_bucket.bucket_website_domain
  description = "The bucket website domain, if website is enabled"
}

output "bucket_website_endpoint" {
  value       = module.s3_bucket.bucket_website_endpoint
  description = "The bucket website endpoint, if website is enabled"
}

output "bucket_id" {
  value       = module.s3_bucket.bucket_id
  description = "Bucket ID"
}

output "bucket_arn" {
  value       = module.s3_bucket.bucket_arn
  description = "Bucket ARN"
}

output "replication_bucket_id" {
  value       = local.s3_replication_enabled ? join("", module.s3_bucket_replication_target[*].bucket_id) : null
  description = "Replication bucket ID"
}

output "replication_bucket_arn" {
  value       = local.s3_replication_enabled ? join("", module.s3_bucket_replication_target[*].bucket_arn) : null
  description = "Replication bucket bucket ARN"
}

output "replication_role_arn" {
  value       = module.s3_bucket.replication_role_arn
  description = "The ARN of the replication IAM Role"
}

output "bucket_region" {
  value       = module.s3_bucket.bucket_region
  description = "Bucket region"
}

output "user_name" {
  value       = module.s3_bucket.user_name
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = module.s3_bucket.user_arn
  description = "The ARN assigned by AWS for the user"
}

output "user_unique_id" {
  value       = module.s3_bucket.user_unique_id
  description = "The user unique ID assigned by AWS"
}

// Terraform does not include null values in outputs, so to simplify testing,
// we replace the null value with an empty string. `coalesce` is used to
// test for null values, as it fails if all values are empty.
output "access_key_id" {
  sensitive   = true
  value       = try(coalesce(module.s3_bucket.access_key_id), "")
  description = "Access Key ID"
}

output "secret_access_key" {
  sensitive   = true
  value       = try(coalesce(module.s3_bucket.secret_access_key), "")
  description = "Secret Access Key. This will be written to the state file in plain-text"
}

output "access_key_id_ssm_path" {
  value       = try(coalesce(module.s3_bucket.access_key_id_ssm_path), "")
  description = "The SSM Path under which the S3 User's access key ID is stored"
}

output "secret_access_key_ssm_path" {
  value       = try(coalesce(module.s3_bucket.secret_access_key_ssm_path), "")
  description = "The SSM Path under which the S3 User's secret access key is stored"
}
