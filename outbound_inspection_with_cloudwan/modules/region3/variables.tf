// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "core_network_id" {
  description = "Cloud WAN Core Network ID"
  type        = string
}

variable "core_network_arn" {
  description = "Cloud WAN Core Network ARN"
  type        = string
}

# Prod VPC 3 Configuration
variable "prod_vpc3_cidr" {
  description = "CIDR block for Prod VPC 3"
  type        = string
  default     = "10.3.0.0/16"
}

variable "prod_vpc3_cwan_subnets" {
  description = "CIDR blocks for Prod VPC 3 Cloud WAN subnets"
  type        = list(string)
  default     = ["10.3.0.0/28", "10.3.0.16/28"]
}

variable "prod_vpc3_endpoint_subnets" {
  description = "CIDR blocks for Prod VPC 3 endpoint subnets"
  type        = list(string)
  default     = ["10.3.0.32/28", "10.3.0.48/28"]
}

variable "prod_vpc3_workload_subnets" {
  description = "CIDR blocks for Prod VPC 3 workload subnets"
  type        = list(string)
  default     = ["10.3.1.0/24", "10.3.2.0/24"]
}

# Inspection VPC 3 Configuration
variable "inspection_vpc3_cidr" {
  description = "CIDR block for Inspection VPC 3"
  type        = string
  default     = "100.64.3.0/24"
}

variable "inspection_vpc3_cwan_subnets" {
  description = "CIDR blocks for Inspection VPC 3 Cloud WAN subnets"
  type        = list(string)
  default     = ["100.64.3.0/28", "100.64.3.16/28"]
}

variable "inspection_vpc3_firewall_subnets" {
  description = "CIDR blocks for Inspection VPC 3 firewall subnets"
  type        = list(string)
  default     = ["100.64.3.32/28", "100.64.3.48/28"]
}

variable "inspection_vpc3_public_subnets" {
  description = "CIDR blocks for Inspection VPC 3 public subnets"
  type        = list(string)
  default     = ["100.64.3.64/28", "100.64.3.80/28"]
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Firewall Configuration
variable "allowed_domains" {
  description = "List of allowed domains for egress traffic"
  type        = list(string)
  default     = [".amazon.com", ".amazonaws.com", ".google.com"]
}
