variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = string
  description = "Name  (e.g. `app` or `db`)"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `{ BusinessUnit = \"XYZ\" }`"
}

variable "acl" {
  type        = string
  default     = "private"
  description = "The canned ACL to apply. We recommend `private` to avoid exposing sensitive information"
}

variable "policy" {
  type        = string
  default     = ""
  description = "A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
}

variable "region" {
  type        = string
  default     = ""
  description = "If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee."
}

variable "force_destroy" {
  type        = string
  default     = "false"
  description = "A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
}

variable "versioning_enabled" {
  type        = string
  default     = "false"
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket."
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`"
}

variable "kms_master_key_id" {
  type        = string
  default     = ""
  description = "The AWS KMS master key ID used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`"
}

variable "enabled" {
  type        = string
  description = "Set to `false` to prevent the module from creating any resources"
  default     = "true"
}

variable "user_enabled" {
  type        = string
  default     = "false"
  description = "Set to `true` to create an S3 user with permission to access the bucket"
}

variable "allowed_bucket_actions" {
  type        = list(string)
  default     = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  description = "List of actions the user is permitted to perform on the S3 bucket"
}

variable "allow_encrypted_uploads_only" {
  type        = string
  default     = "false"
  description = "Set to `true` to prevent uploads of unencrypted objects to S3 bucket"
}

