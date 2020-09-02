terraform {
  required_version = ">= 0.12.0, < 0.14.0"

  required_providers {
    aws   = ">= 3.0, < 4.0"
    local = "~> 1.2"
    null  = "~> 2.0"
  }
}
