terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.68.0, != 4.0.0, != 4.1.0, != 4.2.0, != 4.3.0, != 4.4.0, != 4.5.0, != 4.6.0, != 4.7.0, != 4.8.0, < 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7"
    }
  }
}
