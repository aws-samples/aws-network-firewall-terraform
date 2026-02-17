// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# ---------- Network Firewall ----------
resource "aws_networkfirewall_firewall" "inspection_vpc1" {
  name                = "${var.project_name}-${local.region}-insp-vpc1-nfw1"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.inspection_vpc1.arn
  vpc_id              = aws_vpc.inspection_vpc1.id

  dynamic "subnet_mapping" {
    for_each = aws_subnet.inspection_vpc1_firewall[*].id
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-nfw1"
  }
}

# ---------- Firewall Policy ----------
resource "aws_networkfirewall_firewall_policy" "inspection_vpc1" {
  name = "${var.project_name}-${local.region}-insp-vpc1-nfw1-policy1"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.inspection_vpc1_stateless_drop_ssh.arn
    }

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    stateful_default_actions = ["aws:drop_established", "aws:alert_established"]

    stateful_rule_group_reference {
      priority     = 100
      resource_arn = aws_networkfirewall_rule_group.inspection_vpc1_domain_allow.arn
    }

    stateful_rule_group_reference {
      priority     = 200
      resource_arn = aws_networkfirewall_rule_group.inspection_vpc1_standard_stateful.arn
    }
  }

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-nfw1-policy1"
  }
}

# ---------- Stateless Rule Group - Drop SSH ----------
resource "aws_networkfirewall_rule_group" "inspection_vpc1_stateless_drop_ssh" {
  name        = "${var.project_name}-${local.region}-insp-vpc1-nfw1-dropremote-rg"
  description = "Drop remote SSH connections"
  type        = "STATELESS"
  capacity    = 100

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [6]
              source {
                address_definition = "0.0.0.0/0"
              }
              source_port {
                from_port = 22
                to_port   = 22
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              destination_port {
                from_port = 22
                to_port   = 22
              }
            }
          }
        }
      }
    }
  }

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-nfw1-dropremote-rg"
  }
}

# ---------- Domain Allow List Rule Group ----------
resource "aws_networkfirewall_rule_group" "inspection_vpc1_domain_allow" {
  name        = "${var.project_name}-${local.region}-insp-vpc1-nfw1-domain-allow-rg"
  description = "Allowing access to desired domains"
  type        = "STATEFUL"
  capacity    = 100

  rule_group {
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }

    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = ["10.0.0.0/8"]
        }
      }
    }

    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.allowed_domains
      }
    }
  }

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-nfw1-domain-allow-rg"
  }
}

# ---------- Standard Stateful Rule Group ----------
resource "aws_networkfirewall_rule_group" "inspection_vpc1_standard_stateful" {
  name     = "${var.project_name}-${local.region}-insp-vpc1-nfw1-standard-stateful-rg"
  type     = "STATEFUL"
  capacity = 100

  rule_group {
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }

    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = ["10.0.0.0/8"]
        }
      }
    }

    rules_source {
      stateful_rule {
        action = "ALERT"
        header {
          direction        = "ANY"
          protocol         = "ICMP"
          destination      = "ANY"
          source           = "$HOME_NET"
          destination_port = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["10001"]
        }
      }

      stateful_rule {
        action = "PASS"
        header {
          direction        = "ANY"
          protocol         = "ICMP"
          destination      = "ANY"
          source           = "$HOME_NET"
          destination_port = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["10002"]
        }
      }

      stateful_rule {
        action = "ALERT"
        header {
          direction        = "ANY"
          protocol         = "UDP"
          destination      = "ANY"
          source           = "$HOME_NET"
          destination_port = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["20001"]
        }
      }

      stateful_rule {
        action = "PASS"
        header {
          direction        = "ANY"
          protocol         = "UDP"
          destination      = "ANY"
          source           = "$HOME_NET"
          destination_port = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["20002"]
        }
      }
    }
  }

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-nfw1-standard-stateful-rg"
  }
}

# ---------- Firewall Logging ----------
resource "aws_cloudwatch_log_group" "inspection_vpc1_flow" {
  name              = "/nfw1/flow/${var.project_name}/${local.region}"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-flow-logs"
  }
}

resource "aws_cloudwatch_log_group" "inspection_vpc1_alert" {
  name              = "/nfw1/alert/${var.project_name}/${local.region}"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-alert-logs"
  }
}

resource "aws_networkfirewall_logging_configuration" "inspection_vpc1" {
  firewall_arn = aws_networkfirewall_firewall.inspection_vpc1.arn

  logging_configuration {
    log_destination_config {
      log_type             = "FLOW"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.inspection_vpc1_flow.name
      }
    }

    log_destination_config {
      log_type             = "ALERT"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.inspection_vpc1_alert.name
      }
    }
  }
}

# ---------- Local for Firewall Endpoint IDs ----------
locals {
  inspection_vpc1_firewall_endpoint_ids = [
    for az_index in [0, 1] : [
      for state in aws_networkfirewall_firewall.inspection_vpc1.firewall_status[0].sync_states :
      state.attachment[0].endpoint_id
      if state.availability_zone == data.aws_availability_zones.available.names[az_index]
    ][0]
  ]
}
