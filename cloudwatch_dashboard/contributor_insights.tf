# Contributor Insights Rules for AWS Network Firewall CloudWatch Dashboard

# Top Long-Lived TCP Flows - Age > 350 Seconds
resource "aws_cloudwatch_contributor_insight_rule" "top_long_lived_tcp_flows" {
  rule_name  = "TopLongLivedTCPFlowsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.src_port",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      Filters = [
        {
          Match       = "$.event.netflow.age"
          GreaterThan = 350
        },
        {
          Match = "$.event.proto"
          In    = ["TCP"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# TCP SYN Without SYN-ACK
resource "aws_cloudwatch_contributor_insight_rule" "top_tcp_syn_without_synack" {
  rule_name  = "TopTCPSYNWithoutSYNACKRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.src_port",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      Filters = [
        {
          Match = "$.event.tcp.tcp_flags"
          In    = ["02"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top Source IP by Packets
resource "aws_cloudwatch_contributor_insight_rule" "top_source_ip_by_packets" {
  rule_name  = "TopSourceIPByPacketsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys    = ["$.event.src_ip"]
      ValueOf = "$.event.netflow.pkts"
      Filters = []
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top Source IP by Bytes
resource "aws_cloudwatch_contributor_insight_rule" "top_source_ip_by_bytes" {
  rule_name  = "TopSourceIPByBytesRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys    = ["$.event.src_ip"]
      ValueOf = "$.event.netflow.bytes"
      Filters = []
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top Destination IP by Packets
resource "aws_cloudwatch_contributor_insight_rule" "top_destination_ip_by_packets" {
  rule_name  = "TopDestinationIPByPacketsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys    = ["$.event.dest_ip"]
      ValueOf = "$.event.netflow.pkts"
      Filters = []
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top Destination IP by Bytes
resource "aws_cloudwatch_contributor_insight_rule" "top_destination_ip_by_bytes" {
  rule_name  = "TopDestinationIPByBytesRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys    = ["$.event.dest_ip"]
      ValueOf = "$.event.netflow.bytes"
      Filters = []
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top Source and Destination IP by Packets
resource "aws_cloudwatch_contributor_insight_rule" "top_source_and_destination_ip_by_packets" {
  rule_name  = "TopSourceAndDestinationIPByPacketsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip"
      ]
      ValueOf = "$.event.netflow.pkts"
      Filters = []
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top Source and Destination IP by Bytes
resource "aws_cloudwatch_contributor_insight_rule" "top_source_and_destination_ip_by_bytes" {
  rule_name  = "TopSourceAndDestinationIPByBytesRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip"
      ]
      ValueOf = "$.event.netflow.bytes"
      Filters = []
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top Source Ports
resource "aws_cloudwatch_contributor_insight_rule" "top_source_ports" {
  rule_name  = "TopSourcePortsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys    = ["$.event.src_port"]
      Filters = []
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top Destination Ports
resource "aws_cloudwatch_contributor_insight_rule" "top_destination_ports" {
  rule_name  = "TopDestinationPortsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys    = ["$.event.dest_port"]
      Filters = []
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top TCP Flows
resource "aws_cloudwatch_contributor_insight_rule" "top_tcp_flows" {
  rule_name  = "TopTCPFlowsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      Filters = [
        {
          Match = "$.event.proto"
          In    = ["TCP"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top TCP Flows by Packets
resource "aws_cloudwatch_contributor_insight_rule" "top_tcp_flows_by_packets" {
  rule_name  = "TopTCPFlowsByPacketsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      ValueOf = "$.event.netflow.pkts"
      Filters = [
        {
          Match = "$.event.proto"
          In    = ["TCP"]
        }
      ]
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top TCP Flows by Bytes
resource "aws_cloudwatch_contributor_insight_rule" "top_tcp_flows_by_bytes" {
  rule_name  = "TopTCPFlowsByBytesRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      ValueOf = "$.event.netflow.bytes"
      Filters = [
        {
          Match = "$.event.proto"
          In    = ["TCP"]
        }
      ]
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top UDP Flows
resource "aws_cloudwatch_contributor_insight_rule" "top_udp_flows" {
  rule_name  = "TopUDPFlowsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      Filters = [
        {
          Match = "$.event.proto"
          In    = ["UDP"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top UDP Flows by Packets
resource "aws_cloudwatch_contributor_insight_rule" "top_udp_flows_by_packets" {
  rule_name  = "TopUDPFlowsByPacketsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      ValueOf = "$.event.netflow.pkts"
      Filters = [
        {
          Match = "$.event.proto"
          In    = ["UDP"]
        }
      ]
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top UDP Flows by Bytes
resource "aws_cloudwatch_contributor_insight_rule" "top_udp_flows_by_bytes" {
  rule_name  = "TopUDPFlowsByBytesRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      ValueOf = "$.event.netflow.bytes"
      Filters = [
        {
          Match = "$.event.proto"
          In    = ["UDP"]
        }
      ]
    }
    AggregateOn = "Sum"
  })

  tags = var.tags
}

# Top ICMP Flows
resource "aws_cloudwatch_contributor_insight_rule" "top_icmp_flows" {
  rule_name  = "TopICMPFlowsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_flow_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip"
      ]
      Filters = [
        {
          Match = "$.event.proto"
          In    = ["ICMP"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top Blocked Remote Access Ports (SSH, Telnet, RDP)
resource "aws_cloudwatch_contributor_insight_rule" "top_blocked_remote_access_ports" {
  rule_name  = "TopBlockedRemoteAccessPortsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_alert_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      Filters = [
        {
          Match = "$.event.alert.action"
          In    = ["blocked"]
        },
        {
          Match = "$.event.dest_port"
          In    = ["22", "23", "3389"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top Blocked TCP Flows
resource "aws_cloudwatch_contributor_insight_rule" "top_blocked_tcp_flows" {
  rule_name  = "TopBlockedTCPFlowsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_alert_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      Filters = [
        {
          Match = "$.event.alert.action"
          In    = ["blocked"]
        },
        {
          Match = "$.event.proto"
          In    = ["TCP"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top Blocked UDP Flows
resource "aws_cloudwatch_contributor_insight_rule" "top_blocked_udp_flows" {
  rule_name  = "TopBlockedUDPFlowsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_alert_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = [
        "$.event.src_ip",
        "$.event.dest_ip",
        "$.event.dest_port"
      ]
      Filters = [
        {
          Match = "$.event.alert.action"
          In    = ["blocked"]
        },
        {
          Match = "$.event.proto"
          In    = ["UDP"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top HTTP Host Header
resource "aws_cloudwatch_contributor_insight_rule" "top_http_host_header" {
  rule_name  = "TopHTTPHostHeaderRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_alert_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = ["$.event.http.hostname"]
      Filters = [
        {
          Match = "$.event.alert.action"
          NotIn = ["blocked"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top Blocked HTTP Host Header
resource "aws_cloudwatch_contributor_insight_rule" "top_blocked_http_host_header" {
  rule_name  = "TopBlockedHTTPHostHeaderRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_alert_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = ["$.event.http.hostname"]
      Filters = [
        {
          Match = "$.event.alert.action"
          In    = ["blocked"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top HTTP URI Paths
resource "aws_cloudwatch_contributor_insight_rule" "top_http_uri_paths" {
  rule_name  = "TopHTTPURIPathsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_alert_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys    = ["$.event.http.url"]
      Filters = []
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top HTTP User-Agents
resource "aws_cloudwatch_contributor_insight_rule" "top_http_user_agents" {
  rule_name  = "TopHTTPUserAgentsRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_alert_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys    = ["$.event.http.http_user_agent"]
      Filters = []
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top TLS SNI
resource "aws_cloudwatch_contributor_insight_rule" "top_tls_sni" {
  rule_name  = "TopTLSSNIRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_alert_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = ["$.event.tls.sni"]
      Filters = [
        {
          Match = "$.event.alert.action"
          NotIn = ["blocked"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}

# Top Blocked TLS SNI
resource "aws_cloudwatch_contributor_insight_rule" "top_blocked_tls_sni" {
  rule_name  = "TopBlockedTLSSNIRule-${var.firewall_name}"
  rule_state = var.contributor_insights_rule_state

  rule_definition = jsonencode({
    Schema = {
      Name    = "CloudWatchLogRule"
      Version = 1
    }
    LogGroupNames = [var.firewall_alert_log_group_name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = ["$.event.tls.sni"]
      Filters = [
        {
          Match = "$.event.alert.action"
          In    = ["blocked"]
        }
      ]
    }
    AggregateOn = "Count"
  })

  tags = var.tags
}