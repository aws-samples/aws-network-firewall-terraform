// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "firewall_endpoint_ids" {
  description = "Network Firewall Endpoint IDs per AZ"
  value       = local.firewall_endpoint_ids
}

output "firewall_endpoint_az1" {
  description = "Network Firewall Endpoint ID for AZ1"
  value       = local.firewall_endpoint_ids[0]
}

output "firewall_endpoint_az2" {
  description = "Network Firewall Endpoint ID for AZ2"
  value       = local.firewall_endpoint_ids[1]
}

output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.main.id
}

output "spoke_a_instance_ids" {
  description = "Spoke A EC2 Instance IDs"
  value       = aws_instance.spoke_a[*].id
}

output "spoke_b_instance_ids" {
  description = "Spoke B EC2 Instance IDs"
  value       = aws_instance.spoke_b[*].id
}

output "spoke_a_security_group_id" {
  description = "Spoke A Security Group ID"
  value       = aws_security_group.spoke_a_workload.id
}

output "spoke_b_security_group_id" {
  description = "Spoke B Security Group ID"
  value       = aws_security_group.spoke_b_workload.id
}

output "tgw_route_table_ids" {
  description = "TGW Subnet Route Table IDs"
  value       = aws_route_table.inspection_tgw[*].id
}

output "public_route_table_ids" {
  description = "Public Subnet Route Table IDs"
  value       = aws_route_table.inspection_public[*].id
}

output "inspection_tgw_route_table_id" {
  description = "Inspection TGW Route Table ID"
  value       = aws_ec2_transit_gateway_route_table.inspection.id
}

output "inspection_vpc_attachment_id" {
  description = "Inspection VPC TGW Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.inspection.id
}

output "spoke_a_vpc_id" {
  description = "Spoke A VPC ID"
  value       = aws_vpc.spoke_a.id
}

output "spoke_b_vpc_id" {
  description = "Spoke B VPC ID"
  value       = aws_vpc.spoke_b.id
}

output "inspection_vpc_id" {
  description = "Inspection VPC ID"
  value       = aws_vpc.inspection.id
}

output "availability_zones" {
  description = "Availability Zones used"
  value       = var.availability_zones
}
