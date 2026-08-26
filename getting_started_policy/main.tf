# =============================================================================
# AWS Network Firewall - Getting Started Policy Template (Terraform)
# =============================================================================
# Deploys a firewall policy configured in monitor mode (alert only, no blocking)
# with AWS managed rule groups and a custom Suricata rule group. Designed for
# customers who are starting with Network Firewall and want to observe traffic
# before enabling blocking.
#
# Associate this policy with your existing or new Network Firewall to begin
# monitoring.
#
# To transition to enforcement mode:
# 1. Review alert logs for 1-2 weeks to understand traffic patterns
# 2. Remove override_action blocks from managed rule groups (they will begin blocking)
# 3. Change stateful_default_actions from aws:alert_established_app_layer_to_server
#    to aws:drop_established_app_layer_to_server to begin blocking unmatched traffic
# 4. Add aws:alert_established_app_layer_to_server alongside the drop action so
#    blocked traffic is still logged
# 5. Change custom rules from alert to drop/reject as appropriate
# =============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_partition" "current" {}

# =============================================================================
# Custom Suricata Rule Group
# =============================================================================
# This rule group contains monitoring rules that help you understand your traffic
# patterns. All rules are in alert mode (logging only, no blocking).
# Once you have observed traffic for a sufficient period, you can change specific
# rules from 'alert' to 'drop' or 'reject' to begin blocking.

resource "aws_networkfirewall_rule_group" "custom_rules" {
  capacity = var.custom_rule_group_capacity
  name     = var.custom_rule_group_name
  type     = "STATEFUL"

  description = "Getting started custom rules - all in alert mode for traffic visibility. Change alert to drop/reject once you are ready to begin blocking."

  rule_group {
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }

    rules_source {
      rules_string = <<-EOT
# =========================================================================
# AWS Network Firewall - Getting Started Custom Rules
# =========================================================================
# All rules are in ALERT mode (monitor only, no blocking).
# Once you are comfortable with what traffic the firewall is seeing,
# change 'alert' to 'drop' or 'reject' on rules you want to enforce.
# =========================================================================

# -------------------------------------------------------------------------
# HOME_NET Validation
# -------------------------------------------------------------------------
# Alerts on traffic where neither source nor destination matches $HOME_NET.
# If this rule fires, your HOME_NET variable does not include all internal
# CIDR ranges. Investigate and add the missing ranges.
# The first two rules record the direction a flow matched in (noalert, so they
# never log on their own). The third alerts when neither bit was set, and uses
# a third flowbit so it alerts once per flow rather than once per packet.
# Matches on 'ip' so UDP and ICMP are covered, not just TCP.
# Action: Keep as alert permanently for ongoing validation.
alert ip $HOME_NET any -> any any (msg:"HOME_NET validation - egress from HOME_NET"; noalert; flowbits:set,egress_from_home_net; flow:to_server; sid:900001; rev:1;)
alert ip any any -> $HOME_NET any (msg:"HOME_NET validation - ingress to HOME_NET"; noalert; flowbits:set,ingress_to_home_net; flow:to_server; sid:900002; rev:1;)
alert ip any any -> any any (msg:"HOME_NET validation - traffic not matching HOME_NET variable"; flowbits:isnotset,ingress_to_home_net; flowbits:isnotset,egress_from_home_net; flowbits:isnotset,home_net_alerted; flowbits:set,home_net_alerted; flow:to_server; sid:900003; rev:1;)

# -------------------------------------------------------------------------
# Plaintext HTTP Detection
# -------------------------------------------------------------------------
# Alerts on any plaintext HTTP traffic leaving your network.
# All outbound traffic should be TLS encrypted. Plaintext HTTP may indicate
# misconfigured applications, legacy systems, or potential data exposure.
# The default action will also log this, but this dedicated rule makes it
# easy to search for and alert on specifically.
# Action: Investigate any hits. Consider changing to 'reject' once you
# confirm no legitimate workloads require plaintext HTTP egress.
alert http $HOME_NET any -> $EXTERNAL_NET any (msg:"Plaintext HTTP egress detected - verify this traffic should not be TLS encrypted"; flow:to_server; sid:900010; rev:1;)

# -------------------------------------------------------------------------
# East-West Traffic Monitoring
# -------------------------------------------------------------------------
# These rules help you discover internal traffic patterns between VPCs.
# Many customers deploying NFW for east-west inspection do not have full
# visibility into what lateral flows exist. These rules surface that traffic.

# Alert on any east-west TCP traffic (internal to internal)
alert tcp $HOME_NET any -> $HOME_NET any (msg:"East-West TCP traffic detected"; flow:to_server,established; sid:900100; rev:1;)

# Alert on east-west traffic to common sensitive ports
# These help identify lateral access patterns to databases, admin interfaces,
# and management protocols between your VPCs.
alert tcp $HOME_NET any -> $HOME_NET 3306 (msg:"East-West MySQL/MariaDB (3306)"; flow:to_server; sid:900101; rev:1;)
alert tcp $HOME_NET any -> $HOME_NET 5432 (msg:"East-West PostgreSQL (5432)"; flow:to_server; sid:900102; rev:1;)
alert tcp $HOME_NET any -> $HOME_NET 1433 (msg:"East-West MSSQL (1433)"; flow:to_server; sid:900103; rev:1;)
alert tcp $HOME_NET any -> $HOME_NET 6379 (msg:"East-West Redis (6379)"; flow:to_server; sid:900104; rev:1;)
alert tcp $HOME_NET any -> $HOME_NET 27017 (msg:"East-West MongoDB (27017)"; flow:to_server; sid:900105; rev:1;)
alert tcp $HOME_NET any -> $HOME_NET 22 (msg:"East-West SSH (22)"; flow:to_server; sid:900106; rev:1;)
alert tcp $HOME_NET any -> $HOME_NET 3389 (msg:"East-West RDP (3389)"; flow:to_server; sid:900107; rev:1;)
alert tcp $HOME_NET any -> $HOME_NET 445 (msg:"East-West SMB (445)"; flow:to_server; sid:900108; rev:1;)

# -------------------------------------------------------------------------
# Inbound Traffic Monitoring
# -------------------------------------------------------------------------
# Alerts on any traffic initiated from external sources toward your network.
# In an egress-only or east-west deployment, inbound traffic from the
# internet is unexpected and may indicate a routing misconfiguration.
# Action: Change to 'drop' once you confirm this traffic is unwanted.
alert ip $EXTERNAL_NET any -> $HOME_NET any (msg:"Inbound traffic from EXTERNAL_NET to HOME_NET"; flow:to_server; sid:900200; rev:1;)
      EOT
    }
  }
}

# =============================================================================
# Firewall Policy
# =============================================================================
# Configured in MONITOR MODE:
# - Default action: alert (not drop) - logs unmatched traffic without blocking
# - All managed rule groups: DROP_TO_ALERT override - logs detections without blocking
# - Stream exception policy: REJECT - resets midstream flows for clean reconnection
# - HOME_NET: All RFC 1918 private IP ranges
# - TCP idle timeout: 350 seconds (matching NAT gateway default)

resource "aws_networkfirewall_firewall_policy" "getting_started" {
  name        = var.policy_name
  description = "Getting started policy in monitor mode. Logs all traffic and threat detections without blocking. See template comments for steps to transition to enforcement."

  firewall_policy {
    # Stateless engine: forward everything to stateful for inspection
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    # Stateful engine configuration
    stateful_engine_options {
      rule_order              = "STRICT_ORDER"
      stream_exception_policy = "REJECT"
      flow_timeouts {
        tcp_idle_timeout_seconds = 350
      }
    }

    # Default action: ALERT only (monitor mode, server-directed)
    # Waits for application-layer data (TLS SNI, HTTP host) before alerting.
    # To begin blocking, change to:
    #   stateful_default_actions = ["aws:drop_established_app_layer_to_server", "aws:alert_established_app_layer_to_server"]
    stateful_default_actions = ["aws:alert_established_app_layer_to_server"]

    # Policy variables: HOME_NET set to all RFC 1918 ranges
    policy_variables {
      rule_variables {
        key = "HOME_NET"
        ip_set {
          definition = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
        }
      }
    }

    # =========================================================================
    # Managed Rule Group References
    # =========================================================================
    # All deployed with DROP_TO_ALERT override (monitor mode).
    # Remove the override_action block from each to begin blocking.

    # Priority 1: Active Threat Defense (AWS threat intelligence - powered by MadPot)
    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/AttackInfrastructureStrictOrder"
      priority     = 1
      override {
        action = "DROP_TO_ALERT"
      }
    }

    # Priority 2-5: Domain and IP reputation rule groups
    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/BotNetCommandAndControlDomainsStrictOrder"
      priority     = 2
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/AbusedLegitBotNetCommandAndControlDomainsStrictOrder"
      priority     = 3
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/MalwareDomainsStrictOrder"
      priority     = 4
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/AbusedLegitMalwareDomainsStrictOrder"
      priority     = 5
      override {
        action = "DROP_TO_ALERT"
      }
    }

    # Priority 6-15: Threat signature rule groups
    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesBotnetStrictOrder"
      priority     = 6
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesBotnetWebStrictOrder"
      priority     = 7
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesMalwareStrictOrder"
      priority     = 8
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesMalwareCoinminingStrictOrder"
      priority     = 9
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesExploitsStrictOrder"
      priority     = 10
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesIOCStrictOrder"
      priority     = 11
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesScannersStrictOrder"
      priority     = 12
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesSuspectStrictOrder"
      priority     = 13
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesEmergingEventsStrictOrder"
      priority     = 14
      override {
        action = "DROP_TO_ALERT"
      }
    }

    stateful_rule_group_reference {
      resource_arn = "arn:${data.aws_partition.current.partition}:network-firewall:${var.aws_region}:aws-managed:stateful-rulegroup/ThreatSignaturesDoSStrictOrder"
      priority     = 15
      override {
        action = "DROP_TO_ALERT"
      }
    }

    # Additional threat signature groups available after requesting a
    # stateful rule capacity increase to 50,000 via AWS Service Quotas:
    # - ThreatSignaturesBotnetWindowsStrictOrder (3,400 capacity)
    # - ThreatSignaturesMalwareWebStrictOrder (3,300 capacity)
    # - ThreatSignaturesWebAttacksStrictOrder (1,400 capacity)
    # - ThreatSignaturesPhishingStrictOrder (4,200 capacity)
    # - ThreatSignaturesMalwareMobileStrictOrder (4,000 capacity)

    # Priority 100: Custom rules (evaluated last, after all managed rules)
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.custom_rules.arn
      priority     = 100
    }
  }
}
