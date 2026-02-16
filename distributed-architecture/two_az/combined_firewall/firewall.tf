// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Network Firewall
resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.project_name}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = aws_vpc.main.id

  subnet_mapping {
    subnet_id = aws_subnet.firewall_1.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.firewall_2.id
  }

  tags = {
    Name = "${var.project_name}-firewall"
  }
}

# Firewall Policy
resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.project_name}-firewall-policy"

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
          definition = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
        }
      }
    }
  }

  tags = {
    Name = "${var.project_name}-firewall-policy"
  }
}

# Log Only Rule Group
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

# Firewall Logging
resource "aws_cloudwatch_log_group" "firewall_flow" {
  name              = "/${var.project_name}/nfw/flow"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-flow-logs"
  }
}

resource "aws_cloudwatch_log_group" "firewall_alert" {
  name              = "/${var.project_name}/nfw/alert"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-alert-logs"
  }
}

resource "aws_networkfirewall_logging_configuration" "main" {
  firewall_arn = aws_networkfirewall_firewall.main.arn

  logging_configuration {
    log_destination_config {
      log_type             = "FLOW"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_flow.name
      }
    }

    log_destination_config {
      log_type             = "ALERT"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_alert.name
      }
    }
  }
}

# Local for firewall endpoint IDs per AZ
locals {
  firewall_endpoint_id_az1 = [
    for state in aws_networkfirewall_firewall.main.firewall_status[0].sync_states :
    state.attachment[0].endpoint_id
    if state.availability_zone == var.availability_zone_1
  ][0]

  firewall_endpoint_id_az2 = [
    for state in aws_networkfirewall_firewall.main.firewall_status[0].sync_states :
    state.attachment[0].endpoint_id
    if state.availability_zone == var.availability_zone_2
  ][0]
}
