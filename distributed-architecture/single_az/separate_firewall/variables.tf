// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "aws_region" {
  description = "AWS Region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Availability Zone for deployment"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.2.1.0/24"
}

variable "nlb_subnet_cidr" {
  description = "CIDR block for the NLB subnet"
  type        = string
  default     = "10.2.2.0/24"
}

variable "nat_subnet_cidr" {
  description = "CIDR block for the NAT Gateway subnet"
  type        = string
  default     = "10.2.3.0/24"
}

variable "ingress_firewall_subnet_cidr" {
  description = "CIDR block for the ingress firewall subnet"
  type        = string
  default     = "10.2.16.0/28"
}

variable "egress_firewall_subnet_cidr" {
  description = "CIDR block for the egress firewall subnet"
  type        = string
  default     = "10.2.17.0/28"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "nfw-1az-dual"
}
