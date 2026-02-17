// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Default provider for Core Network (global resource, can be any region)
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = var.project_name
      Terraform = "true"
    }
  }
}

# Provider for Region 1 (us-east-1)
provider "aws" {
  alias  = "region1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = var.project_name
      Terraform = "true"
    }
  }
}

# Provider for Region 2 (us-east-2)
provider "aws" {
  alias  = "region2"
  region = "us-east-2"

  default_tags {
    tags = {
      Project   = var.project_name
      Terraform = "true"
    }
  }
}

# Provider for Region 3 (us-west-2)
provider "aws" {
  alias  = "region3"
  region = "us-west-2"

  default_tags {
    tags = {
      Project   = var.project_name
      Terraform = "true"
    }
  }
}
