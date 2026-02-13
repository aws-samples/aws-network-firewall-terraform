// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#------------------------------------------------------------------------------
# CloudWatch Log Groups for Network Firewall (for manual configuration)
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "firewall_alert" {
  name              = "/nfw/alert-logs"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "firewall-alert-logs-${var.project_name}"
  }
}

resource "aws_cloudwatch_log_group" "firewall_flow" {
  name              = "/nfw/flow-logs"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "firewall-flow-logs-${var.project_name}"
  }
}
