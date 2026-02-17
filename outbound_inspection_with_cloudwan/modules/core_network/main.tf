// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Global Network
resource "aws_networkmanager_global_network" "main" {
  description = "Global Network - Egress Inspection Scenarios"

  tags = {
    Name = "${var.project_name}-inspection-global-network"
  }
}

# Core Network with Policy Document
resource "aws_networkmanager_core_network" "main" {
  global_network_id = aws_networkmanager_global_network.main.id
  description       = "Core Network - Egress Inspection Scenarios"

  tags = {
    Name = "${var.project_name}-inspection-core-network"
  }
}

# Core Network Policy Attachment
resource "aws_networkmanager_core_network_policy_attachment" "main" {
  core_network_id = aws_networkmanager_core_network.main.id
  policy_document = data.aws_networkmanager_core_network_policy_document.main.json
}

# Core Network Policy Document
data "aws_networkmanager_core_network_policy_document" "main" {
  core_network_configuration {
    vpn_ecmp_support = true
    asn_ranges       = ["64520-65525"]

    dynamic "edge_locations" {
      for_each = var.edge_locations
      content {
        location = edge_locations.value
      }
    }
  }

  segments {
    name                          = "Production"
    require_attachment_acceptance = false
  }

  segments {
    name                          = "EgressInspection"
    require_attachment_acceptance = false
  }

  network_function_groups {
    name                          = "EgressInspectionNFG"
    require_attachment_acceptance = false
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type = "tag-exists"
      key  = "domain"
    }

    action {
      association_method = "tag"
      tag_value_of_key   = "domain"
    }
  }
}
