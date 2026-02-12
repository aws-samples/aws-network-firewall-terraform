// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Availability Zone for deployment"
  type        = string
  default     = "us-east-1a"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "nfw-centralized"
}

variable "spoke_a_cidr" {
  description = "CIDR block for Spoke A VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "spoke_b_cidr" {
  description = "CIDR block for Spoke B VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "inspection_vpc_cidr" {
  description = "CIDR block for Inspection VPC"
  type        = string
  default     = "100.64.0.0/16"
}

variable "home_net_cidrs" {
  description = "CIDR blocks for HOME_NET variable in firewall rules"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}
