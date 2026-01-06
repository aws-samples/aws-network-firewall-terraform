# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7"
    }
  }
}

provider "aws" {
  default_tags {
    tags = local.common_tags
  }
}