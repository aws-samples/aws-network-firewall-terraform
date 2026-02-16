// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_1_id" {
  description = "Public Subnet 1 ID"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "Public Subnet 2 ID"
  value       = aws_subnet.public_2.id
}

output "firewall_subnet_1_id" {
  description = "Firewall Subnet 1 ID"
  value       = aws_subnet.firewall_1.id
}

output "firewall_subnet_2_id" {
  description = "Firewall Subnet 2 ID"
  value       = aws_subnet.firewall_2.id
}

output "firewall_id" {
  description = "Network Firewall ID"
  value       = aws_networkfirewall_firewall.main.id
}

output "firewall_arn" {
  description = "Network Firewall ARN"
  value       = aws_networkfirewall_firewall.main.arn
}

output "firewall_endpoint_id_az1" {
  description = "Network Firewall Endpoint ID in AZ1"
  value       = local.firewall_endpoint_id_az1
}

output "firewall_endpoint_id_az2" {
  description = "Network Firewall Endpoint ID in AZ2"
  value       = local.firewall_endpoint_id_az2
}

output "test_instance_1_id" {
  description = "Test Instance 1 ID"
  value       = aws_instance.test_1.id
}

output "test_instance_2_id" {
  description = "Test Instance 2 ID"
  value       = aws_instance.test_2.id
}

output "flow_log_group" {
  description = "CloudWatch Log Group for flow logs"
  value       = aws_cloudwatch_log_group.firewall_flow.name
}

output "alert_log_group" {
  description = "CloudWatch Log Group for alert logs"
  value       = aws_cloudwatch_log_group.firewall_alert.name
}
