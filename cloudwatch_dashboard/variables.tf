# Variables for AWS Network Firewall CloudWatch Dashboard

variable "firewall_name" {
  description = "Enter the firewall name as seen in the firewall console"
  type        = string
}

variable "firewall_subnet_list" {
  description = "Select the firewall endpoint subnet(s)"
  type        = list(string)
  validation {
    condition     = length(var.firewall_subnet_list) > 0
    error_message = "At least one firewall subnet must be specified."
  }
}

variable "firewall_flow_log_group_name" {
  description = "Name of the CloudWatch log group where your firewall flow logs are stored"
  type        = string
}

variable "firewall_alert_log_group_name" {
  description = "Name of the CloudWatch log group where your firewall alert logs are stored"
  type        = string
}

variable "contributor_insights_rule_state" {
  description = "State of the Contributor Insight rules - ENABLED rules actively process logs, DISABLED rules are created but inactive"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.contributor_insights_rule_state)
    error_message = "Contributor Insights rule state must be either ENABLED or DISABLED."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}