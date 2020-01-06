## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acl | The canned ACL to apply. We recommend `private` to avoid exposing sensitive information | string | `private` | no |
| allow_encrypted_uploads_only | Set to `true` to prevent uploads of unencrypted objects to S3 bucket | bool | `false` | no |
| allowed_bucket_actions | List of actions the user is permitted to perform on the S3 bucket | list(string) | `<list>` | no |
| attributes | Additional attributes (e.g. `1`) | list(string) | `<list>` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes` | string | `-` | no |
| enabled | Set to false to prevent the module from creating any resources | bool | `true` | no |
| environment | Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT' | string | `` | no |
| force_destroy | A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable | bool | `false` | no |
| kms_master_key_arn | The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms` | string | `` | no |
| lifecycle_rule_enabled | Enable or disable lifecycle rule | bool | `false` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | string | `` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | string | `` | no |
| noncurrent_version_expiration_days | Specifies when noncurrent object versions expire | number | `90` | no |
| noncurrent_version_transition_days | Number of days to persist in the standard storage tier before moving to the glacier tier infrequent access tier | number | `30` | no |
| policy | A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy | string | `` | no |
| prefix | Prefix identifying one or more objects to which the rule applies | string | `` | no |
| region | If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee | string | `` | no |
| sse_algorithm | The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms` | string | `AES256` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | string | `` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | map(string) | `<map>` | no |
| user_enabled | Set to `true` to create an IAM user with permission to access the bucket | bool | `false` | no |
| versioning_enabled | A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket | bool | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| access_key_id | The access key ID |
| bucket_arn | Bucket ARN |
| bucket_domain_name | FQDN of bucket |
| bucket_id | Bucket Name (aka ID) |
| enabled | Is module enabled |
| secret_access_key | The secret access key. This will be written to the state file in plain-text |
| user_arn | The ARN assigned by AWS for the user |
| user_enabled | Is user creation enabled |
| user_name | Normalized IAM user name |
| user_unique_id | The user unique ID assigned by AWS |

