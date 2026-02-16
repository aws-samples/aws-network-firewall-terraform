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

variable "private_subnet_az1_cidr" {
  description = "CIDR block for the private subnet in AZ1"
  type        = string
  default     = "10.2.1.0/24"
}

variable "private_subnet_az2_cidr" {
  description = "CIDR block for the private subnet in AZ2"
  type        = string
  default     = "10.2.4.0/24"
}

variable "nlb_subnet_az1_cidr" {
  description = "CIDR block for the NLB subnet in AZ1"
  type        = string
  default     = "10.2.2.0/24"
}

variable "nlb_subnet_az2_cidr" {
  description = "CIDR block for the NLB subnet in AZ2"
  type        = string
  default     = "10.2.5.0/24"
}

variable "nat_subnet_az1_cidr" {
  description = "CIDR block for the NAT Gateway subnet in AZ1"
  type        = string
  default     = "10.2.3.0/24"
}

variable "nat_subnet_az2_cidr" {
  description = "CIDR block for the NAT Gateway subnet in AZ2"
  type        = string
  default     = "10.2.6.0/24"
}

variable "ingress_firewall_subnet_az1_cidr" {
  description = "CIDR block for the ingress firewall subnet in AZ1"
  type        = string
  default     = "10.2.16.0/28"
}

variable "ingress_firewall_subnet_az2_cidr" {
  description = "CIDR block for the ingress firewall subnet in AZ2"
  type        = string
  default     = "10.2.18.0/28"
}

variable "egress_firewall_subnet_az1_cidr" {
  description = "CIDR block for the egress firewall subnet in AZ1"
  type        = string
  default     = "10.2.17.0/28"
}

variable "egress_firewall_subnet_az2_cidr" {
  description = "CIDR block for the egress firewall subnet in AZ2"
  type        = string
  default     = "10.2.19.0/28"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "nfw-2az-dual"
}
