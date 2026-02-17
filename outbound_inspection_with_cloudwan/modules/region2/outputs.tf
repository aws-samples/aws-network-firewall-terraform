// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "prod_vpc2_id" {
  description = "Prod VPC 2 ID"
  value       = aws_vpc.prod_vpc2.id
}

output "prod_vpc4_id" {
  description = "Prod VPC 4 ID"
  value       = aws_vpc.prod_vpc4.id
}

output "prod_vpc2_attachment_id" {
  description = "Prod VPC 2 Cloud WAN Attachment ID"
  value       = aws_networkmanager_vpc_attachment.prod_vpc2.id
}

output "prod_vpc4_firewall_endpoint_ids" {
  description = "Prod VPC 4 Network Firewall Endpoint IDs"
  value       = local.prod_vpc4_firewall_endpoint_ids
}
