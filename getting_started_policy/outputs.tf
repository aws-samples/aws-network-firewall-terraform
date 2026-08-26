output "firewall_policy_arn" {
  description = "ARN of the created firewall policy - use this when creating or updating your Network Firewall"
  value       = aws_networkfirewall_firewall_policy.getting_started.arn
}

output "custom_rule_group_arn" {
  description = "ARN of the custom rule group"
  value       = aws_networkfirewall_rule_group.custom_rules.arn
}

output "next_steps" {
  description = "What to do after deploying this template"
  value       = <<-EOT
    1. Associate this policy with your Network Firewall.
    2. Configure logging (alert logs to CloudWatch Logs recommended).
    3. Monitor alert logs for 1-2 weeks to understand traffic patterns.
    4. Remove override blocks from managed rule groups to begin blocking threats.
    5. Change stateful_default_actions from alert to drop to begin blocking unmatched traffic.
    6. Add domain allowlist rules to the custom rule group based on observed traffic.
    7. Request a stateful rule capacity increase to 50,000 via Service Quotas to add more managed rule groups.
  EOT
}
