# Additional dashboard widgets - this file contains the remaining widgets for the dashboard

locals {
  # Additional widgets for the dashboard
  additional_widgets = [
    # Top Talkers Section Header
    {
      height = 1
      width  = 24
      y      = 34
      x      = 0
      type   = "text"
      properties = {
        markdown   = "# Top Talkers"
        background = "transparent"
      }
    },

    # Top Source IP by Packets
    {
      height = 7
      width  = 6
      y      = 35
      x      = 0
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Source IP by Packets"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_source_ip_by_packets.rule_name
        }
      }
    },

    # Top Source IP by Bytes
    {
      height = 7
      width  = 6
      y      = 35
      x      = 6
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Source IP by Bytes"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_source_ip_by_bytes.rule_name
        }
      }
    },

    # Top Destination IP by Packets
    {
      height = 7
      width  = 6
      y      = 35
      x      = 12
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Destination IP by Packets"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_destination_ip_by_packets.rule_name
        }
      }
    },

    # Top Destination IP by Bytes
    {
      height = 7
      width  = 6
      y      = 35
      x      = 18
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Destination IP by Bytes"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_destination_ip_by_bytes.rule_name
        }
      }
    },

    # Top Source and Destination IP by Packets
    {
      height = 7
      width  = 12
      y      = 42
      x      = 0
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Source and Destination IP by Packets"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_source_and_destination_ip_by_packets.rule_name
        }
      }
    },

    # Top Source and Destination IP by Bytes
    {
      height = 7
      width  = 12
      y      = 42
      x      = 12
      type   = "metric"
      properties = {
        period = 60
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_source_and_destination_ip_by_bytes.rule_name
        }
        stacked = false
        view    = "timeSeries"
        yAxis = {
          left = {
            showUnits = false
          }
          right = {
            showUnits = false
          }
        }
        region = data.aws_region.current.name
        title  = "Top Source and Destination IP by Bytes"
        legend = {
          position = "right"
        }
      }
    },

    # Top Protocols Section Header
    {
      height = 1
      width  = 24
      y      = 49
      x      = 0
      type   = "text"
      properties = {
        markdown   = "# Top Protocols"
        background = "transparent"
      }
    },

    # Top Protocols
    {
      height = 7
      width  = 6
      y      = 50
      x      = 0
      type   = "log"
      properties = {
        query   = "SOURCE '${var.firewall_flow_log_group_name}' | stats count() as proto by event.proto\n| sort proto desc\n| limit 10"
        region  = data.aws_region.current.name
        stacked = false
        title   = "Top Protocols"
        view    = "pie"
      }
    },

    # Top Application Layer Protocols Detected
    {
      height = 7
      width  = 6
      y      = 50
      x      = 6
      type   = "log"
      properties = {
        query   = "SOURCE '${var.firewall_flow_log_group_name}' | stats count() as app_proto by event.app_proto\n| sort app_proto desc\n| limit 10"
        region  = data.aws_region.current.name
        stacked = false
        view    = "pie"
        title   = "Top Application Layer Protocols Detected"
      }
    },

    # Top Source Port
    {
      height = 7
      width  = 6
      y      = 50
      x      = 12
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Source Port"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_source_ports.rule_name
        }
      }
    },

    # Top Destination Port
    {
      height = 7
      width  = 6
      y      = 50
      x      = 18
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Destination Port"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_destination_ports.rule_name
        }
      }
    },

    # Top TCP Flows
    {
      height = 7
      width  = 6
      y      = 57
      x      = 0
      type   = "metric"
      properties = {
        period = 60
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_tcp_flows.rule_name
        }
        stacked = false
        view    = "timeSeries"
        yAxis = {
          left = {
            showUnits = false
          }
          right = {
            showUnits = false
          }
        }
        region = data.aws_region.current.name
        title  = "Top TCP Flows"
        legend = {
          position = "right"
        }
      }
    },

    # Top TCP Flows by Packets
    {
      height = 7
      width  = 6
      y      = 57
      x      = 6
      type   = "metric"
      properties = {
        period = 60
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_tcp_flows_by_packets.rule_name
        }
        stacked = false
        view    = "timeSeries"
        yAxis = {
          left = {
            showUnits = false
          }
          right = {
            showUnits = false
          }
        }
        region = data.aws_region.current.name
        title  = "Top TCP Flows by Packets"
        legend = {
          position = "right"
        }
      }
    },

    # Top TCP Flows by Bytes
    {
      height = 7
      width  = 6
      y      = 57
      x      = 12
      type   = "metric"
      properties = {
        period = 60
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_tcp_flows_by_bytes.rule_name
        }
        stacked = false
        view    = "timeSeries"
        yAxis = {
          left = {
            showUnits = false
          }
          right = {
            showUnits = false
          }
        }
        region = data.aws_region.current.name
        title  = "Top TCP Flows by Bytes"
        legend = {
          position = "right"
        }
      }
    },

    # Top TCP Flags
    {
      height = 7
      width  = 6
      y      = 57
      x      = 18
      type   = "log"
      properties = {
        query  = "SOURCE '${var.firewall_flow_log_group_name}' | stats count() as tcp_flags by event.tcp.tcp_flags\n| sort tcp_flags desc\n| limit 10"
        region = data.aws_region.current.name
        title  = "Top TCP Flags"
        view   = "pie"
      }
    },

    # Top UDP Flows
    {
      height = 7
      width  = 6
      y      = 64
      x      = 0
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top UDP Flows"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_udp_flows.rule_name
        }
      }
    },

    # Top UDP Flows by Packets
    {
      height = 7
      width  = 6
      y      = 64
      x      = 6
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top UDP Flows by Packets"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_udp_flows_by_packets.rule_name
        }
      }
    },

    # Top UDP Flows by Bytes
    {
      height = 7
      width  = 6
      y      = 64
      x      = 12
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top UDP Flows by Bytes"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_udp_flows_by_bytes.rule_name
        }
      }
    },

    # Top ICMP Flows
    {
      height = 7
      width  = 6
      y      = 64
      x      = 18
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top ICMP Flows"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_icmp_flows.rule_name
        }
      }
    },

    # Alert Log Analysis Section Header
    {
      height = 1
      width  = 24
      y      = 71
      x      = 0
      type   = "text"
      properties = {
        markdown   = "# Alert Log Analysis"
        background = "transparent"
      }
    },

    # Rule Summary Section Header
    {
      height = 1
      width  = 24
      y      = 72
      x      = 0
      type   = "text"
      properties = {
        markdown   = "## Rule Summary"
        background = "transparent"
      }
    },

    # Top Drop/Reject Rules
    {
      height = 7
      width  = 6
      y      = 73
      x      = 0
      type   = "log"
      properties = {
        query   = "SOURCE '${var.firewall_alert_log_group_name}' | stats count (*) as Count by event.alert.signature_id as SID, event.alert.action as Action, event.alert.signature as Message, event.proto as Proto\n| display SID, Action, Message, Proto, Count\n| filter event.alert.action = 'blocked'\n| sort Count desc\n| limit 10"
        region  = data.aws_region.current.name
        stacked = false
        title   = "Top Drop/Reject Rules"
        view    = "table"
      }
    },

    # Top Alert Rules
    {
      height = 7
      width  = 6
      y      = 73
      x      = 6
      type   = "log"
      properties = {
        query   = "SOURCE '${var.firewall_alert_log_group_name}' | stats count (*) as Count by event.alert.signature_id as SID, event.alert.action as Action, event.alert.signature as Message, event.proto as Proto\n| display SID, Action, Message, Proto, Count\n| filter event.alert.action != 'blocked'\n| sort Count desc\n| limit 10"
        region  = data.aws_region.current.name
        stacked = false
        title   = "Top Alert Rules"
        view    = "table"
      }
    },

    # Recent Alert Log Events
    {
      height = 7
      width  = 12
      y      = 73
      x      = 12
      type   = "log"
      properties = {
        query   = "SOURCE '${var.firewall_alert_log_group_name}' | fields event.timestamp as Time, event.alert.signature_id as SID, event.alert.signature as Message, event.proto as Proto, event.src_ip as Src_IP, event.src_port as Src_Port, event.dest_ip as Dest_IP, event.dest_port as Dest_Port\n| sort event.timestamp desc\n| limit 10"
        region  = data.aws_region.current.name
        stacked = false
        title   = "Recent Alert Log Events"
        view    = "table"
      }
    },

    # Top Blocked Source IPs
    {
      height = 7
      width  = 6
      y      = 80
      x      = 0
      type   = "log"
      properties = {
        query  = "SOURCE '${var.firewall_alert_log_group_name}' | stats count() as blocked_src_ip by event.src_ip as src_ip\n| filter event.alert.action = 'blocked'\n| sort blocked_src_ip desc\n| limit 10"
        region = data.aws_region.current.name
        title  = "Top Blocked Source IPs"
        view   = "pie"
      }
    },

    # Top Blocked Destination IPs
    {
      height = 7
      width  = 6
      y      = 80
      x      = 6
      type   = "log"
      properties = {
        query  = "SOURCE '${var.firewall_alert_log_group_name}' | stats count() as blocked_dest_ip by event.dest_ip as dest_ip\n| filter event.alert.action = 'blocked'\n| sort blocked_dest_ip desc\n| limit 10"
        region = data.aws_region.current.name
        title  = "Top Blocked Destination IPs"
        view   = "pie"
      }
    },

    # Top Blocked Destination Ports
    {
      height = 7
      width  = 6
      y      = 80
      x      = 12
      type   = "log"
      properties = {
        query   = "SOURCE '${var.firewall_alert_log_group_name}' | stats count() as blocked_dest_port by event.dest_port as dest_port\n| filter event.alert.action = 'blocked'\n| sort blocked_dest_port desc\n| limit 10"
        region  = data.aws_region.current.name
        stacked = false
        title   = "Top Blocked Destination Ports"
        view    = "pie"
      }
    },

    # Top Blocked Remote Access Ports
    {
      height = 7
      width  = 6
      y      = 80
      x      = 18
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Blocked Remote Access Ports - Telnet, SSH, RDP"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_blocked_remote_access_ports.rule_name
        }
      }
    },

    # Top Blocked TCP Flows
    {
      height = 7
      width  = 12
      y      = 87
      x      = 0
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Blocked TCP Flows"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_blocked_tcp_flows.rule_name
        }
      }
    },

    # Top Blocked UDP Flows
    {
      type   = "metric"
      height = 7
      width  = 12
      y      = 87
      x      = 12
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top Blocked UDP Flows"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_blocked_udp_flows.rule_name
        }
      }
    },

    # HTTP & TLS Section Header
    {
      height = 1
      width  = 24
      y      = 94
      x      = 0
      type   = "text"
      properties = {
        markdown   = "## HTTP & TLS"
        background = "transparent"
      }
    },

    # Top HTTP Host Header
    {
      height = 7
      width  = 6
      y      = 95
      x      = 0
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top HTTP Host Header"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_http_host_header.rule_name
        }
      }
    },

    # Top Blocked HTTP Host Header
    {
      height = 7
      width  = 6
      y      = 95
      x      = 6
      type   = "metric"
      properties = {
        period = 60
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_blocked_http_host_header.rule_name
        }
        stacked = false
        view    = "timeSeries"
        yAxis = {
          left = {
            showUnits = false
          }
          right = {
            showUnits = false
          }
        }
        region = data.aws_region.current.name
        title  = "Top Blocked HTTP Host Header"
        legend = {
          position = "right"
        }
      }
    },

    # Top HTTP URI Paths
    {
      height = 7
      width  = 6
      y      = 95
      x      = 12
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top HTTP URI Paths"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_http_uri_paths.rule_name
        }
      }
    },

    # Top HTTP User-Agents
    {
      height = 7
      width  = 6
      y      = 95
      x      = 18
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top HTTP User-Agents"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_http_user_agents.rule_name
        }
      }
    },

    # Top TLS SNI
    {
      height = 7
      width  = 6
      y      = 102
      x      = 0
      type   = "metric"
      properties = {
        period   = 60
        region   = data.aws_region.current.name
        stacked  = false
        timezone = "local"
        title    = "Top TLS SNI"
        view     = "timeSeries"
        legend = {
          position = "right"
        }
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_tls_sni.rule_name
        }
      }
    },

    # Top Blocked TLS SNI
    {
      height = 7
      width  = 6
      y      = 102
      x      = 6
      type   = "metric"
      properties = {
        period = 60
        insightRule = {
          maxContributorCount = 10
          orderBy             = "Sum"
          ruleName            = aws_cloudwatch_contributor_insight_rule.top_blocked_tls_sni.rule_name
        }
        stacked = false
        view    = "timeSeries"
        yAxis = {
          left = {
            showUnits = false
          }
          right = {
            showUnits = false
          }
        }
        region = data.aws_region.current.name
        title  = "Top Blocked TLS SNI"
        legend = {
          position = "right"
        }
      }
    },

    # Top PrivateLink Endpoint Candidates
    {
      height = 7
      width  = 12
      y      = 102
      x      = 12
      type   = "log"
      properties = {
        query  = "SOURCE '${var.firewall_alert_log_group_name}' | stats count(*) as Count by event.src_ip as Source_IP, event.dest_ip as Dest_IP, event.app_proto as App_Proto, event.tls.sni as SNI, event.http.hostname as Hostname\n| filter event.tls.sni like \"s3\" or event.http.hostname like \"s3\" or event.tls.sni like \"dynamodb\" or event.http.hostname like \"dynamodb\" or event.tls.sni like \"backup\" or event.http.hostname like \"backup\"\n| display Source_IP, Dest_IP, App_Proto, SNI, Hostname, Count\n| sort Count desc\n| limit 10"
        region = data.aws_region.current.name
        title  = "Top PrivateLink Endpoint Candidates (S3, DynamoDB, & Backup)"
        view   = "table"
      }
    }
  ]
}