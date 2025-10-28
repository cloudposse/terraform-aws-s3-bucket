terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.27"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7"
    }
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.11.0"
    }
  }
}
