// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "prod_vpc3_id" {
  description = "Prod VPC 3 ID"
  value       = aws_vpc.prod_vpc3.id
}

output "inspection_vpc3_id" {
  description = "Inspection VPC 3 ID"
  value       = aws_vpc.inspection_vpc3.id
}

output "prod_vpc3_attachment_id" {
  description = "Prod VPC 3 Cloud WAN Attachment ID"
  value       = aws_networkmanager_vpc_attachment.prod_vpc3.id
}

output "inspection_vpc3_attachment_id" {
  description = "Inspection VPC 3 Cloud WAN Attachment ID"
  value       = aws_networkmanager_vpc_attachment.inspection_vpc3.id
}

output "firewall_endpoint_ids" {
  description = "Network Firewall Endpoint IDs"
  value       = local.inspection_vpc3_firewall_endpoint_ids
}
