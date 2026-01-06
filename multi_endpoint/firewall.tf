# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Basic Rule Group
resource "aws_networkfirewall_rule_group" "basic_rules" {
  capacity = 100
  name     = "${var.project_name}-basic-allow-rules"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_string = "# Empty rule group"
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = {
    Name = "${var.project_name}-basic-rule-group"
  }
}

# Firewall Policy
resource "aws_networkfirewall_firewall_policy" "multi_endpoint_policy" {
  name = "${var.project_name}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_default_actions           = ["aws:alert_established"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.basic_rules.arn
      priority     = 100
    }

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    policy_variables {
      rule_variables {
        key = "HOME_NET"
        ip_set {
          definition = [var.vpc_cidr]
        }
      }
    }
  }

  tags = {
    Name = "${var.project_name}-firewall-policy"
  }
}

# Network Firewall with Primary Endpoint
resource "aws_networkfirewall_firewall" "multi_endpoint" {
  name                = "${var.project_name}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.multi_endpoint_policy.arn
  vpc_id              = aws_vpc.main.id

  # Primary endpoint
  subnet_mapping {
    subnet_id = aws_subnet.primary_firewall.id
  }

  tags = {
    Name = "${var.project_name}-multi-endpoint-firewall"
  }
}

# Secondary VPC Endpoint Association (Native Terraform Resource)
resource "aws_networkfirewall_vpc_endpoint_association" "secondary_endpoint" {
  firewall_arn = aws_networkfirewall_firewall.multi_endpoint.arn
  vpc_id       = aws_vpc.main.id

  subnet_mapping {
    subnet_id = aws_subnet.secondary_firewall.id
  }

  tags = {
    Name = "${var.project_name}-secondary-endpoint"
  }
}

# Extract endpoint IDs directly from RESOURCES (not data sources)
# This ensures Terraform knows the dependency chain and waits for resources to be created
locals {
  # Primary endpoint ID - single AZ deployment so we take the first sync_state
  primary_endpoint_id = tolist(aws_networkfirewall_firewall.multi_endpoint.firewall_status[0].sync_states)[0].attachment[0].endpoint_id

  # Secondary endpoint ID - single AZ deployment so we take the first association_sync_state
  secondary_endpoint_id = tolist(tolist(aws_networkfirewall_vpc_endpoint_association.secondary_endpoint.vpc_endpoint_association_status)[0].association_sync_state)[0].attachment[0].endpoint_id
}
