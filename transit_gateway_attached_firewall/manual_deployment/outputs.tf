// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.main.id
}

output "spoke_a_instance_id" {
  description = "Spoke A EC2 Instance ID"
  value       = aws_instance.spoke_a.id
}

output "spoke_a_security_group_id" {
  description = "Spoke A Security Group ID"
  value       = aws_security_group.spoke_a_instance.id
}

output "spoke_b_security_group_id" {
  description = "Spoke B Security Group ID"
  value       = aws_security_group.spoke_b_instance.id
}

output "egress_tgw_route_table_id" {
  description = "Egress TGW Subnet Route Table ID"
  value       = aws_route_table.egress_tgw.id
}

output "egress_public_route_table_id" {
  description = "Egress Public Subnet Route Table ID"
  value       = aws_route_table.egress_public.id
}

output "tgw_egress_route_table_id" {
  description = "TGW Egress Route Table ID"
  value       = aws_ec2_transit_gateway_route_table.egress.id
}

output "egress_vpc_attachment_id" {
  description = "Egress VPC TGW Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.egress.id
}
