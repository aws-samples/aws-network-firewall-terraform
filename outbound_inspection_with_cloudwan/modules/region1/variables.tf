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

# Prod VPC 1 Configuration
variable "prod_vpc1_cidr" {
  description = "CIDR block for Prod VPC 1"
  type        = string
  default     = "10.1.0.0/16"
}

variable "prod_vpc1_cwan_subnets" {
  description = "CIDR blocks for Prod VPC 1 Cloud WAN subnets"
  type        = list(string)
  default     = ["10.1.0.0/28", "10.1.0.16/28"]
}

variable "prod_vpc1_endpoint_subnets" {
  description = "CIDR blocks for Prod VPC 1 endpoint subnets"
  type        = list(string)
  default     = ["10.1.0.32/28", "10.1.0.48/28"]
}

variable "prod_vpc1_workload_subnets" {
  description = "CIDR blocks for Prod VPC 1 workload subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

# Inspection VPC 1 Configuration
variable "inspection_vpc1_cidr" {
  description = "CIDR block for Inspection VPC 1"
  type        = string
  default     = "100.64.1.0/24"
}

variable "inspection_vpc1_cwan_subnets" {
  description = "CIDR blocks for Inspection VPC 1 Cloud WAN subnets"
  type        = list(string)
  default     = ["100.64.1.0/28", "100.64.1.16/28"]
}

variable "inspection_vpc1_firewall_subnets" {
  description = "CIDR blocks for Inspection VPC 1 firewall subnets"
  type        = list(string)
  default     = ["100.64.1.32/28", "100.64.1.48/28"]
}

variable "inspection_vpc1_public_subnets" {
  description = "CIDR blocks for Inspection VPC 1 public subnets"
  type        = list(string)
  default     = ["100.64.1.64/28", "100.64.1.80/28"]
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
