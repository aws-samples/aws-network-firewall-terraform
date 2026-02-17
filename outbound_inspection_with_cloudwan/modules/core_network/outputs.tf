// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "global_network_id" {
  description = "Global Network ID"
  value       = aws_networkmanager_global_network.main.id
}

output "core_network_id" {
  description = "Core Network ID"
  value       = aws_networkmanager_core_network.main.id
}

output "core_network_arn" {
  description = "Core Network ARN"
  value       = aws_networkmanager_core_network.main.arn
}
