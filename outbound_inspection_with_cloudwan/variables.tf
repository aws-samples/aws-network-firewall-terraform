// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloudwan-egress"
}

variable "edge_locations" {
  description = "List of edge locations for the Core Network"
  type        = list(string)
  default     = ["us-east-1", "us-east-2", "us-west-2"]
}

variable "instance_type" {
  description = "EC2 instance type for workload instances"
  type        = string
  default     = "t2.micro"
}

variable "allowed_domains" {
  description = "List of allowed domains for egress traffic"
  type        = list(string)
  default     = [".amazon.com", ".amazonaws.com", ".google.com"]
}
