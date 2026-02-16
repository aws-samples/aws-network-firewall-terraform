// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "nfw-distributed-separate-2az"
      ManagedBy = "Terraform"
    }
  }
}
