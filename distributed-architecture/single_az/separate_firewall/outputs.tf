// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = aws_subnet.private.id
}

output "nlb_subnet_id" {
  description = "Network Load Balancer Subnet ID"
  value       = aws_subnet.nlb.id
}

output "nat_subnet_id" {
  description = "NAT Gateway Subnet ID"
  value       = aws_subnet.nat.id
}

output "ingress_firewall_subnet_id" {
  description = "Ingress Firewall Subnet ID"
  value       = aws_subnet.ingress_firewall.id
}

output "egress_firewall_subnet_id" {
  description = "Egress Firewall Subnet ID"
  value       = aws_subnet.egress_firewall.id
}

output "ingress_firewall_id" {
  description = "Ingress Network Firewall ID"
  value       = aws_networkfirewall_firewall.ingress.id
}

output "egress_firewall_id" {
  description = "Egress Network Firewall ID"
  value       = aws_networkfirewall_firewall.egress.id
}

output "ingress_firewall_endpoint_id" {
  description = "Ingress Network Firewall Endpoint ID"
  value       = local.ingress_firewall_endpoint_id
}

output "egress_firewall_endpoint_id" {
  description = "Egress Network Firewall Endpoint ID"
  value       = local.egress_firewall_endpoint_id
}

output "nlb_dns_name" {
  description = "Network Load Balancer DNS Name"
  value       = aws_lb.main.dns_name
}

output "nlb_arn" {
  description = "Network Load Balancer ARN"
  value       = aws_lb.main.arn
}

output "private_instance_1_id" {
  description = "Private EC2 Instance 1 ID"
  value       = aws_instance.private_1.id
}

output "private_instance_2_id" {
  description = "Private EC2 Instance 2 ID"
  value       = aws_instance.private_2.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "ingress_flow_log_group" {
  description = "Ingress Network Firewall Flow Log Group"
  value       = aws_cloudwatch_log_group.ingress_flow.name
}

output "ingress_alert_log_group" {
  description = "Ingress Network Firewall Alert Log Group"
  value       = aws_cloudwatch_log_group.ingress_alert.name
}

output "egress_flow_log_group" {
  description = "Egress Network Firewall Flow Log Group"
  value       = aws_cloudwatch_log_group.egress_flow.name
}

output "egress_alert_log_group" {
  description = "Egress Network Firewall Alert Log Group"
  value       = aws_cloudwatch_log_group.egress_alert.name
}