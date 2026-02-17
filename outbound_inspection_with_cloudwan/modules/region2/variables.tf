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

# Prod VPC 2 Configuration
variable "prod_vpc2_cidr" {
  description = "CIDR block for Prod VPC 2"
  type        = string
  default     = "10.2.0.0/16"
}

variable "prod_vpc2_cwan_subnets" {
  description = "CIDR blocks for Prod VPC 2 Cloud WAN subnets"
  type        = list(string)
  default     = ["10.2.0.0/28", "10.2.0.16/28"]
}

variable "prod_vpc2_endpoint_subnets" {
  description = "CIDR blocks for Prod VPC 2 endpoint subnets"
  type        = list(string)
  default     = ["10.2.0.32/28", "10.2.0.48/28"]
}

variable "prod_vpc2_workload_subnets" {
  description = "CIDR blocks for Prod VPC 2 workload subnets"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

# Prod VPC 4 Configuration (with local firewall)
variable "prod_vpc4_cidr" {
  description = "CIDR block for Prod VPC 4"
  type        = string
  default     = "10.4.0.0/16"
}

variable "prod_vpc4_firewall_subnets" {
  description = "CIDR blocks for Prod VPC 4 firewall subnets"
  type        = list(string)
  default     = ["10.4.0.0/28", "10.4.0.16/28"]
}

variable "prod_vpc4_workload_subnets" {
  description = "CIDR blocks for Prod VPC 4 workload subnets"
  type        = list(string)
  default     = ["10.4.1.0/24", "10.4.2.0/24"]
}

variable "prod_vpc4_public_subnets" {
  description = "CIDR blocks for Prod VPC 4 public subnets"
  type        = list(string)
  default     = ["10.4.3.0/24", "10.4.4.0/24"]
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
