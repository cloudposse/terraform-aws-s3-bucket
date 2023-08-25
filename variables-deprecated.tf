variable "lifecycle_rule_ids" {
  type        = list(string)
  default     = []
  description = "DEPRECATED (use `lifecycle_configuration_rules`): A list of IDs to assign to corresponding `lifecycle_rules`"
}

variable "lifecycle_rules" {
  type = list(object({
    prefix  = string
    enabled = bool
    tags    = map(string)

    enable_glacier_transition            = bool
    enable_deeparchive_transition        = bool
    enable_standard_ia_transition        = bool
    enable_current_object_expiration     = bool
    enable_noncurrent_version_expiration = bool

    abort_incomplete_multipart_upload_days         = number
    noncurrent_version_glacier_transition_days     = number
    noncurrent_version_deeparchive_transition_days = number
    noncurrent_version_expiration_days             = number

    standard_transition_days    = number
    glacier_transition_days     = number
    deeparchive_transition_days = number
    expiration_days             = number
  }))
  default     = null
  description = "DEPRECATED (`use lifecycle_configuration_rules`): A list of lifecycle rules"
}

variable "replication_rules" {
  type        = list(any)
  default     = null
  description = "DEPRECATED (use `s3_replication_rules`): Specifies the replication rules for S3 bucket replication if enabled. You must also set s3_replication_enabled to true."
}
