variable "namespace" {
  description = "Namespace (e.g. `eg` or `cp`)"
  type        = "string"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = "string"
}

variable "name" {
  description = "Name  (e.g. `app` or `db`)"
  type        = "string"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "acl" {
  description = "The canned ACL to apply. We recommend log-delivery-write for compatibility with AWS services"
  default     = "log-delivery-write"
}

variable "policy" {
  description = "A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
  default     = ""
}

variable "region" {
  description = "If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee."
  default     = ""
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = "false"
}

variable "versioning_enabled" {
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket."
  default     = "false"
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms"
  default     = ""
}

variable "enabled" {
  description = "Set to `false` to prevent the module from creating any resources"
  default     = "true"
}

# User variables

variable "user_enabled" {
  description = "Set to `true` to create an S3 user with permission to access the bucket"
  default     = "false"
}

variable "allowed_bucket_actions" {
  type        = "list"
  default     = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  description = "List of actions to permit for S3 bucket"
}
