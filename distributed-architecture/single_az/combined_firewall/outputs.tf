// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "firewall_subnet_id" {
  description = "Firewall Subnet ID"
  value       = aws_subnet.firewall.id
}

output "firewall_id" {
  description = "Network Firewall ID"
  value       = aws_networkfirewall_firewall.main.id
}

output "firewall_arn" {
  description = "Network Firewall ARN"
  value       = aws_networkfirewall_firewall.main.arn
}

output "firewall_endpoint_id" {
  description = "Network Firewall Endpoint ID"
  value       = local.firewall_endpoint_id
}

output "test_instance_id" {
  description = "Test Instance ID"
  value       = aws_instance.test.id
}

output "flow_log_group" {
  description = "CloudWatch Log Group for flow logs"
  value       = aws_cloudwatch_log_group.firewall_flow.name
}

output "alert_log_group" {
  description = "CloudWatch Log Group for alert logs"
  value       = aws_cloudwatch_log_group.firewall_alert.name
}
