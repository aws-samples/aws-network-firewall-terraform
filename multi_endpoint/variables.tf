# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "availability_zone" {
  description = "Availability Zone for deployment"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "nfw-multi-endpoint"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

locals {
  # Automatically calculate subnet CIDRs from VPC CIDR
  private_subnet_cidr            = cidrsubnet(var.vpc_cidr, 8, 1)    # 10.2.1.0/24
  nlb_subnet_cidr                = cidrsubnet(var.vpc_cidr, 8, 2)    # 10.2.2.0/24
  primary_firewall_subnet_cidr   = cidrsubnet(var.vpc_cidr, 12, 240) # 10.2.15.0/28
  secondary_firewall_subnet_cidr = cidrsubnet(var.vpc_cidr, 12, 272) # 10.2.17.0/28
  nat_subnet_cidr                = cidrsubnet(var.vpc_cidr, 12, 256) # 10.2.16.0/28

  common_tags = {
    Project     = var.project_name
    Environment = "demo"
    Terraform   = "true"
  }
}