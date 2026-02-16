// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "aws_region" {
  description = "AWS Region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone_1" {
  description = "First Availability Zone for deployment"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Second Availability Zone for deployment"
  type        = string
  default     = "us-east-1b"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.2.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.2.2.0/24"
}

variable "firewall_subnet_1_cidr" {
  description = "CIDR block for the first firewall subnet"
  type        = string
  default     = "10.2.16.0/28"
}

variable "firewall_subnet_2_cidr" {
  description = "CIDR block for the second firewall subnet"
  type        = string
  default     = "10.2.16.16/28"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "nfw-distributed-2az"
}
