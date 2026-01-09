# AWS Network Firewall CloudWatch Dashboard

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values for subnet query string generation
locals {
  subnet_query_parts  = [for subnet in var.firewall_subnet_list : "\"Subnet Id\"=\"${subnet}\""]
  subnet_query_string = join(" OR ", local.subnet_query_parts)

  # Console URLs for different partitions
  console_urls = {
    "aws"        = "https://console.aws.amazon.com"
    "aws-cn"     = "https://${data.aws_region.current.name}.console.amazonaws.cn"
    "aws-us-gov" = "https://${data.aws_region.current.name}.console.amazonaws-us-gov.com"
  }

  # ARN patterns for different partitions
  arn_patterns = {
    "aws"        = "arn:aws"
    "aws-cn"     = "arn:aws-cn"
    "aws-us-gov" = "arn:aws-us-gov"
  }

  # Get partition from region
  partition = split("-", data.aws_region.current.name)[0] == "cn" ? "aws-cn" : (
    contains(["us-gov-east-1", "us-gov-west-1"], data.aws_region.current.name) ? "aws-us-gov" : "aws"
  )

  console_url = local.console_urls[local.partition]
  arn_pattern = local.arn_patterns[local.partition]

  # Log resource ARN pattern based on partition
  log_resource_arn = "${local.arn_pattern}:logs:*:*:*"
}