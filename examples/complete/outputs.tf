output "bucket_domain_name" {
  value       = module.s3_bucket.bucket_domain_name
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = module.s3_bucket.bucket_id
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = module.s3_bucket.bucket_arn
  description = "Bucket ARN"
}

output "replication_bucket_id" {
  value       = local.replication_enabled ? join("", module.s3_bucket_replication_target.*.bucket_id) : null
  description = "Bucket Name (aka ID)"
}

output "replication_bucket_arn" {
  value       = local.replication_enabled ? join("", module.s3_bucket_replication_target.*.bucket_arn) : null
  description = "Bucket ARN"
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
