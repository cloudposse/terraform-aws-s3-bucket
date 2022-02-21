variable "grants" {
  type = list(object({
    id          = string
    type        = string
    permissions = list(string)
    uri         = string
  }))
  default = null

  description = "DEPRECATED (replaced by `acl_grants`): A list of policy grants for the bucket. Conflicts with `acl`. Set `acl` to `null` to use this."
}

locals {
  acl_grants = var.grants == null ? var.acl_grants : flatten(
    [
      for g in var.grants : [
        for p in g.permissions : {
          id         = g.id
          type       = g.type
          permission = p
          uri        = g.uri
        }
      ]
  ])
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
  description = "DEPRECATED: A list of lifecycle rules"
}

locals {
  lifecycle_configuration_rules = var.lifecycle_rules == null ? var.lifecycle_configuration_rules : (
    [for i, v in var.lifecycle_rules : {
      id      = "rule-${i + 1}"
      prefix  = v.prefix
      enabled = v.enabled
      tags    = v.tags

      enable_glacier_transition            = v.enable_glacier_transition
      enable_deeparchive_transition        = v.enable_deeparchive_transition
      enable_standard_ia_transition        = v.enable_standard_ia_transition
      enable_current_object_expiration     = v.enable_current_object_expiration
      enable_noncurrent_version_expiration = v.enable_noncurrent_version_expiration

      abort_incomplete_multipart_upload_days         = v.abort_incomplete_multipart_upload_days
      noncurrent_version_glacier_transition_days     = v.noncurrent_version_glacier_transition_days
      noncurrent_version_deeparchive_transition_days = v.noncurrent_version_deeparchive_transition_days
      noncurrent_version_expiration_days             = v.noncurrent_version_expiration_days

      standard_transition_days    = v.standard_transition_days
      glacier_transition_days     = v.glacier_transition_days
      deeparchive_transition_days = v.deeparchive_transition_days
      expiration_days             = v.expiration_days
    }]
  )
}