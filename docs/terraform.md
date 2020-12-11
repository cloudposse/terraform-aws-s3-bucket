<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | >= 2.0 |
| local | >= 1.2 |
| null | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| abort\_incomplete\_multipart\_upload\_days | Maximum time (in days) that you want to allow multipart uploads to remain in progress | `number` | `5` | no |
| acl | The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply. We recommend `private` to avoid exposing sensitive information. Conflicts with `grants`. | `string` | `"private"` | no |
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| allow\_encrypted\_uploads\_only | Set to `true` to prevent uploads of unencrypted objects to S3 bucket | `bool` | `false` | no |
| allowed\_bucket\_actions | List of actions the user is permitted to perform on the S3 bucket | `list(string)` | <pre>[<br>  "s3:PutObject",<br>  "s3:PutObjectAcl",<br>  "s3:GetObject",<br>  "s3:DeleteObject",<br>  "s3:ListBucket",<br>  "s3:ListBucketMultipartUploads",<br>  "s3:GetBucketLocation",<br>  "s3:AbortMultipartUpload"<br>]</pre> | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| block\_public\_acls | Set to `false` to disable the blocking of new public access lists on the bucket | `bool` | `true` | no |
| block\_public\_policy | Set to `false` to disable the blocking of new public policies on the bucket | `bool` | `true` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| cors\_rule\_inputs | Specifies the allowed headers, methods, origins and exposed headers when using CORS on this bucket | <pre>list(object({<br>    allowed_headers = list(string)<br>    allowed_methods = list(string)<br>    allowed_origins = list(string)<br>    expose_headers  = list(string)<br>    max_age_seconds = number<br>  }))</pre> | `null` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| enable\_glacier\_transition | Enables the transition to AWS Glacier which can cause unnecessary costs for huge amount of small files | `bool` | `true` | no |
| enable\_standard\_ia\_transition | Enables the transition to STANDARD\_IA | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| expiration\_days | Number of days after which to expunge the objects | `number` | `90` | no |
| force\_destroy | A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable | `bool` | `false` | no |
| glacier\_transition\_days | Number of days after which to move the data to the glacier storage tier | `number` | `60` | no |
| grants | An ACL policy grant. Conflicts with `acl`. Set `acl` to `null` to use this. | <pre>list(object({<br>    id          = string<br>    type        = string<br>    permissions = list(string)<br>    uri         = string<br>  }))</pre> | `null` | no |
| id\_length\_limit | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| ignore\_public\_acls | Set to `false` to disable the ignoring of public access lists on the bucket | `bool` | `true` | no |
| kms\_master\_key\_arn | The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms` | `string` | `""` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| lifecycle\_rule\_enabled | Enable or disable lifecycle rule | `bool` | `false` | no |
| lifecycle\_tags | Tags filter. Used to manage object lifecycle events | `map(string)` | `{}` | no |
| logging | Bucket access logging configuration. | <pre>object({<br>    bucket_name = string<br>    prefix      = string<br>  })</pre> | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| noncurrent\_version\_expiration\_days | Specifies when noncurrent object versions expire | `number` | `90` | no |
| noncurrent\_version\_transition\_days | Number of days to persist in the standard storage tier before moving to the glacier tier infrequent access tier | `number` | `30` | no |
| policy | A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy | `string` | `""` | no |
| prefix | Prefix identifying one or more objects to which the rule applies | `string` | `""` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| replication\_rules | Specifies the replication rules if S3 bucket replication is enabled | `list(any)` | `null` | no |
| restrict\_public\_buckets | Set to `false` to disable the restricting of making the bucket public | `bool` | `true` | no |
| s3\_replica\_bucket\_arn | The ARN of the S3 replica bucket (destination) | `string` | `""` | no |
| s3\_replication\_enabled | Set this to true and specify `s3_replica_bucket_arn` to enable replication. `versioning_enabled` must also be `true`. | `bool` | `false` | no |
| sse\_algorithm | The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms` | `string` | `"AES256"` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| standard\_transition\_days | Number of days to persist in the standard storage tier before moving to the infrequent access tier | `number` | `30` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| user\_enabled | Set to `true` to create an IAM user with permission to access the bucket | `bool` | `false` | no |
| versioning\_enabled | A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | The access key ID |
| bucket\_arn | Bucket ARN |
| bucket\_domain\_name | FQDN of bucket |
| bucket\_id | Bucket Name (aka ID) |
| bucket\_region | Bucket region |
| bucket\_regional\_domain\_name | The bucket region-specific domain name |
| enabled | Is module enabled |
| secret\_access\_key | The secret access key. This will be written to the state file in plain-text |
| user\_arn | The ARN assigned by AWS for the user |
| user\_enabled | Is user creation enabled |
| user\_name | Normalized IAM user name |
| user\_unique\_id | The user unique ID assigned by AWS |

<!-- markdownlint-restore -->
