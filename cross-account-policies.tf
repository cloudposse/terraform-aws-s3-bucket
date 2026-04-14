data "aws_caller_identity" "cross_account" {
  count = local.enabled && length(var.cross_account_bucket_policy_stacks) > 0 ? 1 : 0
}

module "cross_account_policy_stacks" {
  for_each = local.enabled ? local.cross_account_policy_refs : {}

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = each.value.component
  tenant      = each.value.tenant
  environment = each.value.environment
  stage       = each.value.stage

  context = module.this.context
}
