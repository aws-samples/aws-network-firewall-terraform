// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#------------------------------------------------------------------------------
# Local values for firewall endpoint
#------------------------------------------------------------------------------
locals {
  firewall_endpoint_id = one([
    for state in aws_networkfirewall_firewall.main.firewall_status[0].sync_states :
    state.attachment[0].endpoint_id
    if state.attachment[0].subnet_id == aws_subnet.inspection_firewall.id
  ])
}

#------------------------------------------------------------------------------
# Network Firewall Rule Groups
#------------------------------------------------------------------------------
resource "aws_networkfirewall_rule_group" "log_only" {
  capacity    = 100
  name        = "basic-log-rules"
  type        = "STATEFUL"
  description = "Simple rule group to log specific protocols"

  rule_group {
    rules_source {
      rules_string = <<-EOF
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
      EOF
    }

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = {
    Name = "basic-log-rules-${var.project_name}"
  }
}

resource "aws_networkfirewall_rule_group" "egress_allow_list" {
  capacity    = 1000
  name        = "egress-allow-list-example-rule-group"
  type        = "STATEFUL"
  description = "Example best practice egress allow list rule group"

  rule_group {
    rules_source {
      rules_string = <<-EOF
        # Block, but do not log any ingress traffic
        drop ip any any -> $HOME_NET any (msg:"Ingress traffic to HOME_NET Blocked"; flow:to_server; sid:98228398;)

        # Silently allow TCP 3-way handshake to be setup by $HOME_NET clients
        pass tcp $HOME_NET any -> any any (flow:not_established, to_server; msg:"pass rules do not alert/log"; sid:9918156;)
        pass tcp any any -> $HOME_NET any (flow:not_established, to_client; msg:"pass rules do not alert/log"; sid:9918199;)

        # Silently (do not log) allow low risk protocols out to anywhere
        pass ntp $HOME_NET any -> any 123 (flow:to_server; msg:"pass rules do not alert/log"; sid:9829158;)

        # Alert on risky geos
        alert ip $HOME_NET any -> any any (msg:"Egress traffic to RU"; flow:to_server; geoip:dst,RU; metadata:geo RU; sid:8733172;)
        alert ip $HOME_NET any -> any any (msg:"Egress traffic to CN"; flow:to_server; geoip:dst,CN; metadata:geo CN; sid:873381;)

        # Block high risk TLDs
        reject tls $HOME_NET any -> any any (tls.sni; content:".ru"; nocase; msg:"High risk TLD blocked"; flow:to_server; sid:20233181;)
        reject http $HOME_NET any -> any any (http.host; content:".ru"; msg:"High risk TLD blocked"; flow:to_server; sid:20235181;)
        reject tls $HOME_NET any -> any any (tls.sni; content:".xyz"; nocase; msg:"High risk TLD blocked"; flow:to_server; sid:20232181;)
        reject http $HOME_NET any -> any any (http.host; content:".xyz"; msg:"High risk TLD blocked"; flow:to_server; sid:20235281;)
        reject tls $HOME_NET any -> any any (tls.sni; content:".info"; nocase; msg:"High risk TLD blocked"; flow:to_server; sid:10233181;)
        reject http $HOME_NET any -> any any (http.host; content:".info"; msg:"High risk TLD blocked"; flow:to_server; sid:10235181;)
        reject tls $HOME_NET any -> any any (tls.sni; content:".onion"; nocase; msg:"High risk TLD blocked"; flow:to_server; sid:23233181;)
        reject http $HOME_NET any -> any any (http.host; content:".onion"; msg:"High risk TLD blocked"; flow:to_server; sid:20335181;)

        # Silently allow AWS public service endpoints
        pass tls $HOME_NET any -> any any (tls.sni; content:"ec2messages."; startswith; nocase; content:".amazonaws.com"; endswith; nocase; flow:to_server; sid:20231181;)
        pass tls $HOME_NET any -> any any (tls.sni; content:"ssm."; startswith; nocase; content:".amazonaws.com"; endswith; nocase; flow:to_server; sid:2023116132;)
        pass tls $HOME_NET any -> any any (tls.sni; content:"ssmmessages."; startswith; nocase; content:".amazonaws.com"; endswith; nocase; flow:to_server; sid:2021110133;)

        # Allow-list of strict FQDNs to silently allow
        pass tls $HOME_NET any -> any any (tls.sni; content:"checkip.amazonaws.com"; startswith; nocase; endswith; flow:to_server; sid:202311893;)
        pass http $HOME_NET any -> any any (http.host; content:"checkip.amazonaws.com"; startswith; endswith; flow:to_server; sid:20236893;)

        # Allow-List of strict FQDNs, but still alert on them
        alert tls $HOME_NET any -> any any (tls.sni; content:"www.example.com"; startswith; nocase; endswith; flow:to_server; msg:"TLS SNI Allowed"; sid:202315893;)
        pass tls $HOME_NET any -> any any (tls.sni; content:"www.example.com"; startswith; nocase; endswith; flow:to_server; msg:"pass rules do not alert/log"; sid:202315873;)

        # Block and log any egress traffic not already allowed above
        reject tls $HOME_NET any -> any any (msg:"Default Egress HTTPS Reject"; ssl_state:client_hello; ja4.hash; content:"_"; flowbits:set,blocked; flow:to_server; sid:999991;)
        alert tls $HOME_NET any -> any any (msg:"X25519Kyber768"; flowbits:isnotset,blocked; flowbits:set,X25519Kyber768; noalert; flow:to_server; sid:999993;)
        reject http $HOME_NET any -> any any (msg:"Default Egress HTTP Reject"; flowbits:set,blocked; flow:to_server; sid:999992;)
        reject tcp $HOME_NET any -> any any (msg:"Default Egress TCP Reject"; flowbits:isnotset,blocked; flowbits:isnotset,X25519Kyber768; flow:to_server; sid:999994;)
        drop udp $HOME_NET any -> any any (msg:"Default Egress UDP Drop"; flow:to_server; sid:999995;)
        drop icmp $HOME_NET any -> any any (msg:"Default Egress ICMP Drop"; flow:to_server; sid:999996;)
        drop ip $HOME_NET any -> any any (msg:"Default Egress IP Drop"; ip_proto:!TCP; ip_proto:!UDP; ip_proto:!ICMP; flow:to_server; sid:999997;)
      EOF
    }

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = {
    Name = "egress-allow-list-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Network Firewall Policy
#------------------------------------------------------------------------------
resource "aws_networkfirewall_firewall_policy" "main" {
  name = "egress-firewall-policy-${var.project_name}"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_engine_options {
      rule_order              = "STRICT_ORDER"
      stream_exception_policy = "REJECT"
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.log_only.arn
      priority     = 100
    }

    policy_variables {
      rule_variables {
        key = "HOME_NET"
        ip_set {
          definition = var.home_net_cidrs
        }
      }
    }
  }

  tags = {
    Name = "egress-firewall-policy-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Network Firewall
#------------------------------------------------------------------------------
resource "aws_networkfirewall_firewall" "main" {
  name                = "egress-firewall-${var.project_name}"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = aws_vpc.inspection.id

  subnet_mapping {
    subnet_id = aws_subnet.inspection_firewall.id
  }

  tags = {
    Name = "egress-firewall-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# CloudWatch Log Groups
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "firewall_flow" {
  name              = "/${var.project_name}/egress-fw/flow"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "firewall-flow-logs-${var.project_name}"
  }
}

resource "aws_cloudwatch_log_group" "firewall_alert" {
  name              = "/${var.project_name}/egress-fw/alert"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "firewall-alert-logs-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Network Firewall Logging Configuration
#------------------------------------------------------------------------------
resource "aws_networkfirewall_logging_configuration" "main" {
  firewall_arn = aws_networkfirewall_firewall.main.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_flow.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }

    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_alert.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}
