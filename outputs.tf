output "bucket_domain_name" {
  value       = local.enabled ? join("", aws_s3_bucket.default[*].bucket_domain_name) : ""
  description = "FQDN of bucket"
}

output "bucket_regional_domain_name" {
  value       = local.enabled ? join("", aws_s3_bucket.default[*].bucket_regional_domain_name) : ""
  description = "The bucket region-specific domain name"
}

output "bucket_website_domain" {
  value       = join("", aws_s3_bucket_website_configuration.default[*].website_domain, aws_s3_bucket_website_configuration.redirect[*].website_domain)
  description = "The bucket website domain, if website is enabled"
}

output "bucket_website_endpoint" {
  value       = join("", aws_s3_bucket_website_configuration.default[*].website_endpoint, aws_s3_bucket_website_configuration.redirect[*].website_endpoint)
  description = "The bucket website endpoint, if website is enabled"
}

output "bucket_id" {
  value       = local.enabled ? local.bucket_id : ""
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = local.enabled ? join("", aws_s3_bucket.default[*].arn) : ""
  description = "Bucket ARN"
}

output "bucket_region" {
  value       = local.enabled ? join("", aws_s3_bucket.default[*].region) : ""
  description = "Bucket region"
}

output "enabled" {
  value       = local.enabled
  description = "Is module enabled"
}

output "user_enabled" {
  value       = var.user_enabled
  description = "Is user creation enabled"
}

output "user_name" {
  value       = module.s3_user.user_name
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = module.s3_user.user_arn
  description = "The ARN assigned by AWS for the user"
}

output "user_unique_id" {
  value       = module.s3_user.user_unique_id
  description = "The user unique ID assigned by AWS"
}

output "replication_role_arn" {
  value       = local.enabled && local.replication_enabled ? join("", aws_iam_role.replication[*].arn) : ""
  description = "The ARN of the replication IAM Role"
}

output "access_key_id" {
  sensitive   = true
  value       = module.s3_user.access_key_id
  description = <<-EOT
    The access key ID, if `var.user_enabled && var.access_key_enabled`.
    While sensitive, it does not need to be kept secret, so this is output regardless of `var.store_access_key_in_ssm`.
    EOT
}

output "secret_access_key" {
  sensitive   = true
  value       = module.s3_user.secret_access_key
  description = <<-EOT
    The secret access key will be output if created and not stored in SSM. However, the secret access key, if created,
    will be written to the Terraform state file unencrypted, regardless of any other settings.
    See the [Terraform documentation](https://www.terraform.io/docs/state/sensitive-data.html) for more details.
    EOT
}

output "access_key_id_ssm_path" {
  value       = module.s3_user.access_key_id_ssm_path
  description = "The SSM Path under which the S3 User's access key ID is stored"
}

output "secret_access_key_ssm_path" {
  value       = module.s3_user.secret_access_key_ssm_path
  description = "The SSM Path under which the S3 User's secret access key is stored"
}
