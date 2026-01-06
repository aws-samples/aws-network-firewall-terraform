# Outputs for AWS Network Firewall CloudWatch Dashboard

output "firewall_dashboard_uri" {
  description = "Link to the CloudWatch Dashboard"
  value       = "${local.console_url}/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.firewall_dashboard.dashboard_name}"
}

output "dashboard_name" {
  description = "Name of the created CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.firewall_dashboard.dashboard_name
}

output "contributor_insights_rules" {
  description = "List of created Contributor Insights rules"
  value = [
    aws_cloudwatch_contributor_insight_rule.top_long_lived_tcp_flows.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_tcp_syn_without_synack.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_source_ip_by_packets.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_source_ip_by_bytes.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_destination_ip_by_packets.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_destination_ip_by_bytes.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_source_and_destination_ip_by_packets.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_source_and_destination_ip_by_bytes.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_source_ports.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_destination_ports.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_tcp_flows.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_tcp_flows_by_packets.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_tcp_flows_by_bytes.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_udp_flows.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_udp_flows_by_packets.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_udp_flows_by_bytes.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_icmp_flows.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_blocked_remote_access_ports.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_blocked_tcp_flows.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_blocked_udp_flows.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_http_host_header.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_blocked_http_host_header.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_http_uri_paths.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_http_user_agents.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_tls_sni.rule_name,
    aws_cloudwatch_contributor_insight_rule.top_blocked_tls_sni.rule_name
  ]
}