variable "region" {
  type        = string
  description = "AWS region"
}

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = string
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
}

variable "acl" {
  type        = string
  description = "The canned ACL to apply. We recommend `private` to avoid exposing sensitive information"
}

variable "force_destroy" {
  type        = bool
  description = "A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
}

variable "versioning_enabled" {
  type        = bool
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket"
}

variable "allowed_bucket_actions" {
  type        = list(string)
  default     = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  description = "List of actions the user is permitted to perform on the S3 bucket"
}

variable "allow_encrypted_uploads_only" {
  type        = bool
  description = "Set to `true` to prevent uploads of unencrypted objects to S3 bucket"
}
