// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# ---------- Core Network Outputs ----------
output "global_network_id" {
  description = "Global Network ID"
  value       = module.core_network.global_network_id
}

output "core_network_id" {
  description = "Core Network ID"
  value       = module.core_network.core_network_id
}

output "core_network_arn" {
  description = "Core Network ARN"
  value       = module.core_network.core_network_arn
}

# ---------- Region 1 Outputs ----------
output "region1_prod_vpc1_id" {
  description = "Region 1 - Prod VPC 1 ID"
  value       = module.region1.prod_vpc1_id
}

output "region1_inspection_vpc1_id" {
  description = "Region 1 - Inspection VPC 1 ID"
  value       = module.region1.inspection_vpc1_id
}

output "region1_firewall_endpoint_ids" {
  description = "Region 1 - Network Firewall Endpoint IDs"
  value       = module.region1.firewall_endpoint_ids
}

# ---------- Region 2 Outputs ----------
output "region2_prod_vpc2_id" {
  description = "Region 2 - Prod VPC 2 ID"
  value       = module.region2.prod_vpc2_id
}

output "region2_prod_vpc4_id" {
  description = "Region 2 - Prod VPC 4 ID"
  value       = module.region2.prod_vpc4_id
}

output "region2_prod_vpc4_firewall_endpoint_ids" {
  description = "Region 2 - Prod VPC 4 Network Firewall Endpoint IDs"
  value       = module.region2.prod_vpc4_firewall_endpoint_ids
}

# ---------- Region 3 Outputs ----------
output "region3_prod_vpc3_id" {
  description = "Region 3 - Prod VPC 3 ID"
  value       = module.region3.prod_vpc3_id
}

output "region3_inspection_vpc3_id" {
  description = "Region 3 - Inspection VPC 3 ID"
  value       = module.region3.inspection_vpc3_id
}

output "region3_firewall_endpoint_ids" {
  description = "Region 3 - Network Firewall Endpoint IDs"
  value       = module.region3.firewall_endpoint_ids
}
