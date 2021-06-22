// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_networkfirewall_firewall_policy" "anfw_policy" {
  name = "firewall-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateless_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.drop_icmp.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_domains.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_public_dns_resolvers.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.drop_non_http_between_vpcs.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "drop_icmp" {
  capacity = 1
  name     = "drop-icmp"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "drop_non_http_between_vpcs" {
  capacity = 100
  name     = "drop-non-http-between-vpcs"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "SPOKE_VPCS"
        ip_set {
          definition = [aws_vpc.spoke_vpc_a.cidr_block, aws_vpc.spoke_vpc_b.cidr_block]
        }
      }
    }
    rules_source {
      rules_string = <<EOF
      drop tcp $SPOKE_VPCS any <> $SPOKE_VPCS any (msg:"Blocked TCP that is not HTTP"; flow:established; app-layer-protocol:!http; sid:100; rev:1;)
      drop ip $SPOKE_VPCS any <> $SPOKE_VPCS any (msg: "Block non-TCP traffic."; ip_proto:!TCP; sid:200; rev:1;)
      EOF
    }
  }
}

resource "aws_networkfirewall_rule_group" "block_public_dns_resolvers" {
  capacity = 1
  name     = "block-public-dns"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "DNS"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:50"
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "block_domains" {
  capacity = 100
  name     = "block-domains"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [aws_vpc.spoke_vpc_a.cidr_block, aws_vpc.spoke_vpc_b.cidr_block]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = [".facebook.com", ".twitter.com"]
      }
    }
  }

}


resource "aws_networkfirewall_firewall" "inspection_vpc_anfw" {
  name                = "NetworkFirewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.anfw_policy.arn
  vpc_id              = aws_vpc.inspection_vpc.id

  dynamic "subnet_mapping" {
    for_each = aws_subnet.inspection_vpc_firewall_subnet[*].id

    content {
      subnet_id = subnet_mapping.value
    }
  }

}

resource "aws_cloudwatch_log_group" "anfw_alert_log_group" {
  name              = "/aws/network-firewall/alert"
  retention_in_days = 14
}

resource "random_string" "bucket_random_id" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_s3_bucket" "anfw_flow_bucket" {
  bucket        = "network-firewall-flow-bucket-${random_string.bucket_random_id.id}"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "anfw_flow_bucket_public_access_block" {
  bucket = aws_s3_bucket.anfw_flow_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_networkfirewall_logging_configuration" "anfw_alert_logging_configuration" {
  firewall_arn = aws_networkfirewall_firewall.inspection_vpc_anfw.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.anfw_alert_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        bucketName = aws_s3_bucket.anfw_flow_bucket.bucket
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }
  }
}
