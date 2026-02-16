// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Ingress Network Firewall
resource "aws_networkfirewall_firewall" "ingress" {
  name                = "${var.project_name}-ingress-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.ingress.arn
  vpc_id              = aws_vpc.main.id

  subnet_mapping {
    subnet_id = aws_subnet.ingress_firewall.id
  }

  tags = {
    Name = "${var.project_name}-ingress-firewall"
    Type = "Ingress"
  }
}

# Egress Network Firewall
resource "aws_networkfirewall_firewall" "egress" {
  name                = "${var.project_name}-egress-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.egress.arn
  vpc_id              = aws_vpc.main.id

  subnet_mapping {
    subnet_id = aws_subnet.egress_firewall.id
  }

  tags = {
    Name = "${var.project_name}-egress-firewall"
    Type = "Egress"
  }
}

# Ingress Firewall Policy
resource "aws_networkfirewall_firewall_policy" "ingress" {
  name = "${var.project_name}-ingress-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.log_only.arn
      priority     = 100
    }

    stateful_engine_options {
      rule_order              = "STRICT_ORDER"
      stream_exception_policy = "REJECT"
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
    Name = "${var.project_name}-ingress-firewall-policy"
    Type = "Ingress"
  }
}

# Egress Firewall Policy
resource "aws_networkfirewall_firewall_policy" "egress" {
  name = "${var.project_name}-egress-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.log_only.arn
      priority     = 100
    }

    stateful_engine_options {
      rule_order              = "STRICT_ORDER"
      stream_exception_policy = "REJECT"
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
    Name = "${var.project_name}-egress-firewall-policy"
    Type = "Egress"
  }
}

# Log Only Rule Group (shared by both firewalls)
resource "aws_networkfirewall_rule_group" "log_only" {
  name        = "${var.project_name}-log-rules"
  type        = "STATEFUL"
  capacity    = 100
  description = "Simple rule group to log specific protocols"

  rule_group {
    rules_source {
      rules_string = <<-EOT
        # Alert on risky geos
        alert ip $HOME_NET any -> any any (msg:"Egress traffic to RU"; flow:to_server; geoip:dst,RU; metadata:geo RU; sid:100001;)
        alert ip $HOME_NET any -> any any (msg:"Egress traffic to CN"; flow:to_server; geoip:dst,CN; metadata:geo CN; sid:100002;)

        # Alert on high risk TLDs
        alert tls $HOME_NET any -> any any (tls.sni; content:".ru"; nocase; msg:"High risk TLD blocked"; flow:to_server; sid:100003;)
        alert http $HOME_NET any -> any any (http.host; content:".ru"; msg:"High risk TLD blocked"; flow:to_server; sid:100004;)
        alert tls $HOME_NET any -> any any (tls.sni; content:".xyz"; nocase; msg:"High risk TLD blocked"; flow:to_server; sid:100005;)
        alert http $HOME_NET any -> any any (http.host; content:".xyz"; msg:"High risk TLD blocked"; flow:to_server; sid:100006;)
        alert tls $HOME_NET any -> any any (tls.sni; content:".info"; nocase; msg:"High risk TLD blocked"; flow:to_server; sid:100007;)
        alert http $HOME_NET any -> any any (http.host; content:".info"; msg:"High risk TLD blocked"; flow:to_server; sid:100008;)
        alert tls $HOME_NET any -> any any (tls.sni; content:".onion"; nocase; msg:"High risk TLD blocked"; flow:to_server; sid:100009;)
        alert http $HOME_NET any -> any any (http.host; content:".onion"; msg:"High risk TLD blocked"; flow:to_server; sid:1000010;)

        # Alert on specific protocols
        alert icmp any any -> any any (msg:"Alert on ping"; sid:1000011;)
        alert http any any -> any any (msg:"Alert on http"; sid:1000012;)
        alert tls any any -> any any (msg:"Alert on tls (https)"; sid:1000013;)
        alert ssh any any -> any any (msg:"Alert on ssh"; sid:1000014;)
      EOT
    }

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = {
    Name = "${var.project_name}-log-rules"
  }
}

# Ingress Firewall Logging
resource "aws_cloudwatch_log_group" "ingress_flow" {
  name              = "/${var.project_name}/ingress-firewall/flow"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-ingress-flow-logs"
  }
}

resource "aws_cloudwatch_log_group" "ingress_alert" {
  name              = "/${var.project_name}/ingress-firewall/alert"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-ingress-alert-logs"
  }
}

resource "aws_networkfirewall_logging_configuration" "ingress" {
  firewall_arn = aws_networkfirewall_firewall.ingress.arn

  logging_configuration {
    log_destination_config {
      log_type             = "FLOW"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.ingress_flow.name
      }
    }

    log_destination_config {
      log_type             = "ALERT"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.ingress_alert.name
      }
    }
  }
}

# Egress Firewall Logging
resource "aws_cloudwatch_log_group" "egress_flow" {
  name              = "/${var.project_name}/egress-firewall/flow"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-egress-flow-logs"
  }
}

resource "aws_cloudwatch_log_group" "egress_alert" {
  name              = "/${var.project_name}/egress-firewall/alert"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-egress-alert-logs"
  }
}

resource "aws_networkfirewall_logging_configuration" "egress" {
  firewall_arn = aws_networkfirewall_firewall.egress.arn

  logging_configuration {
    log_destination_config {
      log_type             = "FLOW"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.egress_flow.name
      }
    }

    log_destination_config {
      log_type             = "ALERT"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.egress_alert.name
      }
    }
  }
}

# Local for firewall endpoint IDs
locals {
  ingress_firewall_endpoint_id = [
    for state in aws_networkfirewall_firewall.ingress.firewall_status[0].sync_states :
    state.attachment[0].endpoint_id
    if state.availability_zone == var.availability_zone
  ][0]

  egress_firewall_endpoint_id = [
    for state in aws_networkfirewall_firewall.egress.firewall_status[0].sync_states :
    state.attachment[0].endpoint_id
    if state.availability_zone == var.availability_zone
  ][0]
}
