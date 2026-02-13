// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "tgw-attached-fw"
}

variable "availability_zone" {
  description = "Availability Zone for deployment"
  type        = string
  default     = "us-east-1a"
}

variable "spoke_a_vpc_cidr" {
  description = "CIDR block for Spoke A VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "spoke_b_vpc_cidr" {
  description = "CIDR block for Spoke B VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "egress_vpc_cidr" {
  description = "CIDR block for Egress VPC"
  type        = string
  default     = "100.64.0.0/16"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "home_net_cidrs" {
  description = "HOME_NET CIDR blocks for firewall policy"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}
