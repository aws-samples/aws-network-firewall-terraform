// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {
  required_providers {
    aws = {
      version = ">= 3.44.0"
      source  = "hashicorp/aws"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=2.3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

