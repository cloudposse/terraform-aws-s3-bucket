output "bucket_domain_name" {
  value       = "${module.s3_bucket.bucket_domain_name}"
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = "${module.s3_bucket.bucket_id}"
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = "${module.s3_bucket.bucket_arn}"
  description = "Bucket ARN"
}

output "user_name" {
  value       = "${module.s3_bucket.user_name}"
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = "${module.s3_bucket.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "user_unique_id" {
  value       = "${module.s3_bucket.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "access_key_id" {
  value       = "${module.s3_bucket.access_key_id}"
  description = "The access key ID"
  sensitive   = true
}

output "secret_access_key" {
  value       = "${module.s3_bucket.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
  sensitive   = true
}
