// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "prod_vpc1_id" {
  description = "Prod VPC 1 ID"
  value       = aws_vpc.prod_vpc1.id
}

output "inspection_vpc1_id" {
  description = "Inspection VPC 1 ID"
  value       = aws_vpc.inspection_vpc1.id
}

output "prod_vpc1_attachment_id" {
  description = "Prod VPC 1 Cloud WAN Attachment ID"
  value       = aws_networkmanager_vpc_attachment.prod_vpc1.id
}

output "inspection_vpc1_attachment_id" {
  description = "Inspection VPC 1 Cloud WAN Attachment ID"
  value       = aws_networkmanager_vpc_attachment.inspection_vpc1.id
}

output "firewall_endpoint_ids" {
  description = "Network Firewall Endpoint IDs"
  value       = local.inspection_vpc1_firewall_endpoint_ids
}
