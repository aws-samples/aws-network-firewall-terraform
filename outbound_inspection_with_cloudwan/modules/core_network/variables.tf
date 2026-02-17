// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "edge_locations" {
  description = "List of edge locations for the Core Network"
  type        = list(string)
}
