variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "policy_name" {
  description = "Name for the firewall policy"
  type        = string
  default     = "nfw-getting-started-policy"
}

variable "custom_rule_group_name" {
  description = "Name for the custom Suricata rule group"
  type        = string
  default     = "nfw-getting-started-custom-rules"
}

variable "custom_rule_group_capacity" {
  description = <<-EOT
    Capacity for the custom rule group. Set low initially to maximize managed rule
    coverage. After requesting a capacity increase to 50,000 via Service Quotas,
    create additional custom rule groups with higher capacity for domain allowlists.
  EOT
  type        = number
  default     = 200
}
