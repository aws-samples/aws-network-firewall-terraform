// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_az1_id" {
  description = "Private Subnet AZ1 ID"
  value       = aws_subnet.private_az1.id
}

output "private_subnet_az2_id" {
  description = "Private Subnet AZ2 ID"
  value       = aws_subnet.private_az2.id
}

output "nlb_subnet_az1_id" {
  description = "NLB Subnet AZ1 ID"
  value       = aws_subnet.nlb_az1.id
}

output "nlb_subnet_az2_id" {
  description = "NLB Subnet AZ2 ID"
  value       = aws_subnet.nlb_az2.id
}

output "ingress_firewall_id" {
  description = "Ingress Network Firewall ID"
  value       = aws_networkfirewall_firewall.ingress.id
}

output "egress_firewall_id" {
  description = "Egress Network Firewall ID"
  value       = aws_networkfirewall_firewall.egress.id
}

output "ingress_firewall_endpoint_az1" {
  description = "Ingress Firewall Endpoint AZ1 ID"
  value       = local.ingress_firewall_endpoint_id_az1
}

output "ingress_firewall_endpoint_az2" {
  description = "Ingress Firewall Endpoint AZ2 ID"
  value       = local.ingress_firewall_endpoint_id_az2
}


output "egress_firewall_endpoint_az1" {
  description = "Egress Firewall Endpoint AZ1 ID"
  value       = local.egress_firewall_endpoint_id_az1
}

output "egress_firewall_endpoint_az2" {
  description = "Egress Firewall Endpoint AZ2 ID"
  value       = local.egress_firewall_endpoint_id_az2
}

output "nlb_dns_name" {
  description = "Network Load Balancer DNS Name"
  value       = aws_lb.main.dns_name
}

output "nlb_arn" {
  description = "Network Load Balancer ARN"
  value       = aws_lb.main.arn
}

output "nat_gateway_az1_id" {
  description = "NAT Gateway AZ1 ID"
  value       = aws_nat_gateway.az1.id
}

output "nat_gateway_az2_id" {
  description = "NAT Gateway AZ2 ID"
  value       = aws_nat_gateway.az2.id
}