# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "multi_endpoint_network_firewall_id" {
  description = "Multi-Endpoint Network Firewall ID"
  value       = aws_networkfirewall_firewall.multi_endpoint.id
}

output "multi_endpoint_network_firewall_arn" {
  description = "Multi-Endpoint Network Firewall ARN"
  value       = aws_networkfirewall_firewall.multi_endpoint.arn
}

output "primary_firewall_endpoint_id" {
  description = "Primary Network Firewall Endpoint ID"
  value       = local.primary_endpoint_id
}

output "secondary_firewall_endpoint_id" {
  description = "Secondary Network Firewall Endpoint ID"
  value       = local.secondary_endpoint_id
}

output "secondary_vpc_endpoint_association_arn" {
  description = "Secondary VPC Endpoint Association ARN"
  value       = aws_networkfirewall_vpc_endpoint_association.secondary_endpoint.vpc_endpoint_association_arn
}

output "secondary_vpc_endpoint_association_id" {
  description = "Secondary VPC Endpoint Association ID"
  value       = aws_networkfirewall_vpc_endpoint_association.secondary_endpoint.vpc_endpoint_association_id
}

output "network_load_balancer_dns" {
  description = "Network Load Balancer DNS Name"
  value       = aws_lb.network_load_balancer.dns_name
}

output "network_load_balancer_arn" {
  description = "Network Load Balancer ARN"
  value       = aws_lb.network_load_balancer.arn
}

output "private_instance_id" {
  description = "Private EC2 Instance ID"
  value       = aws_instance.private_instance.id
}

output "private_instance_private_ip" {
  description = "Private EC2 Instance Private IP"
  value       = aws_instance.private_instance.private_ip
}

output "ssm_endpoint_id" {
  description = "SSM VPC Endpoint ID"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_messages_endpoint_id" {
  description = "SSM Messages VPC Endpoint ID"
  value       = aws_vpc_endpoint.ssm_messages.id
}

output "ec2_messages_endpoint_id" {
  description = "EC2 Messages VPC Endpoint ID"
  value       = aws_vpc_endpoint.ec2_messages.id
}

output "traffic_flow_summary" {
  description = "Summary of traffic flows in multi-endpoint architecture"
  value       = <<-EOT
    INGRESS: Internet -> IGW -> SecondaryEndpoint -> NLB -> Private EC2
    EGRESS: Private EC2 -> PrimaryEndpoint -> NAT Gateway -> IGW -> Internet
    ENDPOINTS: Primary endpoint for egress filtering, Secondary endpoint for ingress filtering
    SSM: Private EC2 -> SSM VPC Endpoints (ssm, ssmmessages, ec2messages)
  EOT
}

output "firewall_endpoints" {
  description = "Network Firewall endpoint information"
  value = {
    primary_endpoint_id   = local.primary_endpoint_id
    secondary_endpoint_id = local.secondary_endpoint_id
    primary_subnet_id     = aws_subnet.primary_firewall.id
    secondary_subnet_id   = aws_subnet.secondary_firewall.id
    firewall_arn          = aws_networkfirewall_firewall.multi_endpoint.arn
  }
}

output "subnets" {
  description = "Subnet information"
  value = {
    private_subnet_id            = aws_subnet.private.id
    nlb_subnet_id                = aws_subnet.nlb.id
    nat_subnet_id                = aws_subnet.nat.id
    primary_firewall_subnet_id   = aws_subnet.primary_firewall.id
    secondary_firewall_subnet_id = aws_subnet.secondary_firewall.id
  }
}

output "route_tables" {
  description = "Route table information"
  value = {
    private_route_table_id            = aws_route_table.private.id
    nlb_route_table_id                = aws_route_table.nlb.id
    nat_route_table_id                = aws_route_table.nat.id
    primary_firewall_route_table_id   = aws_route_table.primary_firewall.id
    secondary_firewall_route_table_id = aws_route_table.secondary_firewall.id
    ingress_route_table_id            = aws_route_table.ingress.id
  }
}
