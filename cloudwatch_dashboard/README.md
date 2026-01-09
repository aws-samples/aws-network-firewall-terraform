# AWS Network Firewall CloudWatch Dashboard

## License:

This sample code is made available under the MIT-0 license. See the LICENSE file.

## Summary:

AWS Network Firewall provides a number of tools that you can use to monitor the utilization, availability, and performance of your firewall. Firewall stateless and stateful engine metrics are published in near real-time to Amazon CloudWatch.  CloudWatch alarms can monitor these metrics and send notifications or take actions when a defined threshold is breached.  Configuring logging for the firewall's stateful engine is optional but highly recommended.  Firewall flow and alert logs provide a wealth of information related to network traffic and stateful drop, reject, and alert rule matches.  Publishing firewall flow and alert log events to CloudWatch log groups allows you to take advantage of CloudWatch log analytics tools such as Logs Insights and Contributor Insights.

Included in this project is a Network Firewall CloudWatch dashboard Terraform configuration.  This easy-to-use configuration creates a monitoring dashboard for a single AWS Network Firewall with just a few commands.  Through a single pane of glass, you will be able to visualize and analyze firewall metric and log data in a structured way.  The included dashboard widgets provide insight into areas such as:

* Gateway Load Balancer endpoint [metrics](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-cloudwatch-metrics.html)
* Firewall engine [metrics](https://docs.aws.amazon.com/network-firewall/latest/developerguide/monitoring-cloudwatch.html)
* Top talkers
* Top protocols
* Alert log analysis
* HTTP & TLS flow analysis

## Pricing Considerations:

The AWS Network Firewall CloudWatch dashboard incorporates a number of CloudWatch features including basic monitoring metrics, [vended logs](https://aws.amazon.com/cloudwatch/pricing/#Vended_Logs), Logs Insights queries, Contributor Insights rules, and the dashboard itself.  Please refer to the [Amazon CloudWatch Pricing](https://aws.amazon.com/cloudwatch/pricing/) guide for up-to-date free and paid tier pricing considerations.  By default, the dashboard will query firewall flow and alert log events over a 3 hour time range.  Increasing the time range will scan more log events at an increased cost while reducing the time range will scan fewer log events at a reduced cost.  All of the Logs Insights and Contributor Insights widgets display the top 10 data points by default.  You can choose to edit the Insights queries or change the Top Contributors to a larger value in order to display more results.  The dashboard will not automatically refresh the widget data by default.  You can choose to manually refresh the data within a single widget or all widgets or you can optionally configure the entire dashboard to automatically refresh at a configured time interval.

## Before You Begin

The provided Terraform configuration makes the following two assumptions:

1.  You have already created an AWS Network Firewall in your VPC
2.  Your AWS Network Firewall has been configured to publish firewall flow and alert logs to two different CloudWatch log groups.  For example, firewall flow logs are published to /my-firewall-flow-logs and alert logs are published to /my-firewall-alert-logs.

If you have not deployed AWS Network Firewall in your VPC, you can use one of the available [AWS Network Firewall Deployment Architecture](https://github.com/aws-samples/aws-networkfirewall-cfn-templates) templates to create a firewall.  Once created, configure [CloudWatch log groups](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Working-with-log-groups-and-streams.html) for the firewall flow and alert logs and configure stateful [logging](https://docs.aws.amazon.com/network-firewall/latest/developerguide/firewall-logging.html) as described above.  Fine tune your firewall policy and rule configuration and make sure you are routing traffic symmetrically through the firewall.  With the firewall now in the routed path and publishing metrics and log events, you can now proceed with this AWS Network Firewall CloudWatch dashboard Terraform configuration.

## Installation

The AWS Network Firewall dashboard Terraform configuration will create a monitoring dashboard for a single AWS Network Firewall.  You will deploy this configuration in the same region as your firewall.

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configured with appropriate permissions
- An existing AWS Network Firewall with flow and alert logging configured

### Deployment Steps

1. **Clone or download this repository**
   ```bash
   git clone <repository-url>
   cd aws-network-firewall-terraform/cloudwatch_dashboard
   ```

2. **Create a terraform.tfvars file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edit the `terraform.tfvars` file with your specific values:
   ```hcl
   firewall_name                   = "my-network-firewall"
   firewall_subnet_list           = ["subnet-12345678", "subnet-87654321"]
   firewall_flow_log_group_name   = "/aws/networkfirewall/flowlogs"
   firewall_alert_log_group_name  = "/aws/networkfirewall/alertlogs"
   contributor_insights_rule_state = "ENABLED"
   
   tags = {
     Environment = "production"
     Project     = "network-security"
   }
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Plan the deployment**
   ```bash
   terraform plan
   ```

5. **Apply the configuration**
   ```bash
   terraform apply
   ```

When deploying, you will need to provide the following variables:

* **firewall_name:**  Firewall name as seen in the **VPC > Network Firewall > Firewalls** console
* **firewall_subnet_list:**  The firewall subnet IDs to which your firewall endpoints are attached.  The firewall subnets can be found on the **Firewall details** tab of your firewall in the **VPC > Network Firewall > Firewalls** console.
* **firewall_flow_log_group_name:**  The name of the CloudWatch log group where your firewall flow logs are stored
* **firewall_alert_log_group_name:**  The name of the CloudWatch log group where your firewall alert logs are stored

Once the deployment is complete, the dashboard URL will be displayed in the output. You can also find it in the CloudWatch Dashboards console. Note that it can take a few minutes for the Logs Insights and Contributor Insights widgets to display data. Some widgets may not display data points if you don't have log events that match the query parameters.

## Removal

You can delete the AWS Network Firewall CloudWatch dashboard and all of the associated resources with a single command.  Deleting the dashboard will not impact the routing and network traffic inspection performed by the firewall.

```bash
terraform destroy
```

## Multi-Region and Multi-Partition Support

This Terraform configuration automatically detects the AWS partition (standard, China, or GovCloud) and adjusts the console URLs accordingly. The configuration supports deployment in:

- **AWS Standard Regions** (console.aws.amazon.com)
- **AWS China Regions** (console.amazonaws.cn) 
- **AWS GovCloud Regions** (console.amazonaws-us-gov.com)

## Configuration Files

The Terraform configuration is organized into several files:

- **main.tf** - Data sources and local values
- **variables.tf** - Input variable definitions
- **outputs.tf** - Output definitions
- **dashboard.tf** - Main dashboard resource
- **dashboard_widgets.tf** - Additional dashboard widgets
- **contributor_insights.tf** - CloudWatch Contributor Insights rules
- **terraform.tfvars.example** - Example variables file

## Dashboard Widget Details:

### Firewall Endpoints:

|Widget Name | Type | Usage|
|------|------|------|
|Firewall Endpoint ENI (GWLBe/VPCe) Metrics | Metrics | Per-endpoint packet, byte, and connections metrics|
|Per Endpoint Utilization Gbps | Metrics | Per-endpoint utilization in Gbps during the most recent period|
|ActiveConnections | Metrics | Active connections per-endpoint during the most recent period and time range|
|BytesProcessed | Metrics | Bytes processed per-endpoint during the most recent period and time range|

### Firewall Engines:

#### Stateless:

|Widget Name | Type | Usage|
|------|------|------|
|Stateless Engine Metrics | Metrics | All available stateless engine metrics per availability zone|
|Stateless Passed Packets | Metrics | Packets passed by stateless rules or default action during the most recent period and time range|
|Stateless Dropped Packets - Rule Action | Metrics | Packets dropped by stateless rules or stateless default action during the most recent period and time range|
|Stateless Dropped Packets - Other | Metrics | Packets dropped by stateless packet validation checks during the most recent period and time range|

#### Stateful:

|Widget Name | Type | Usage|
|------|------|------|
|Stateful Engine Metrics | Metrics | All available stateful engine metrics per availability zone|
|Stateful Passed Packets | Metrics | Packets passed by stateful rules or default action during the most recent period and time range|
|Stateful Dropped Packets | Metrics | Packets dropped by stateful rules or stateful default action during the most recent period and time range|
|Stateful Rejected Packets | Metrics | Packets rejected due to Reject stateful rule action during the most recent period and time range|
|TLS Inspection | Metrics | Displays all available SSL/TLS metrics related to [inbound/outbound TLS inspection configurations](https://docs.aws.amazon.com/network-firewall/latest/developerguide/tls-inspection-configurations.html)|
|Stream Exception Policy Packets| Metrics | Displays count of packets related to long-lived established connections that the receiving firewall appliance is seeing mid-conversation.  The chosen [stream exception policy](https://docs.aws.amazon.com/network-firewall/latest/developerguide/stream-exception-policy.html) action determines how the firewall handles these midstream packets.|
|Top Long-Lived TCP Flows - Age > 350s | Contributor Insights | Count of TCP flows active for longer than the Gateway Load Balancer's 350 second idle timeout.  This can be used to identify long-lived TCP flows that may be affected by the chosen stream exception policy action.|
|Top TCP Flows - SYN Without SYN-ACK | Contributor Insights | Count of flows failing the TCP 3-way handshake.  During initial firewall configuration, this might be a sign of misconfigured routing in the return path.  Failing to received a SYN-ACK from the server can also be due to Network ACL, security group, or on-premises firewall rules.|

### Top Talkers

|Widget Name | Type | Usage|
|------|------|------|
|Top Source IP by Packets | Contributor Insights | Sum of packets by Source IP|
|Top Source IP by Bytes | Contributor Insights | Sum of bytes by Source IP|
|Top Destination IP by Packets | Contributor Insights | Sum of packets by Destination IP|
|Top Destination IP by Bytes | Contributor Insights | Sum of bytes by Destination IP|
|Top Source and Destination IP by Packets | Contributor Insights | Sum of packets by Source and Destination IP|
|Top Source and Destination IP by Bytes | Contributor Insights | Sum of bytes by Source and Destination IP|

### Top Protocols

|Widget Name | Type | Usage|
|------|------|------|
|Top Protocols | Logs Insights | Count of top protocols|
|Top Application Layer Protocols Detected | Logs Insights | Count of top application layer protocols automatically detected by Suricata|
|Top Source Port| Contributor Insights | Count of top source ports|
|Top Destination Port| Contributor Insights | Count of top destination ports|
|Top TCP Flows| Contributor Insights | Count of TCP flows based on source IP, destination IP, and destination port|
|Top TCP Flows by Packets| Contributor Insights | Sum of packets for TCP flows based on source IP, destination IP, and destination port|
|Top TCP Flows by Bytes| Contributor Insights | Sum of bytes for TCP flows based on source IP, destination IP, and destination port|
|Top TCP Flags| Logs Insights | Top TCP flag combinations from firewall flow logs represented in hexadecimal form.  For example, an established and gracefully terminated connection is represented as 1b which equals 27 in decimal.  This equates to FIN (1) + SYN (2) + PSH (8) + ACK (16) flag control bits being set.
|Top UDP Flows| Contributor Insights | Count of UDP flows based on source IP, destination IP, and destination port|
|Top UDP Flows by Packets| Contributor Insights | Sum of packets for UDP flows based on source IP, destination IP, and destination port|
|Top UDP Flows by Bytes| Contributor Insights | Sum of bytes for UDP flows based on source IP, destination IP, and destination port|
|Top ICMP Flows| Contributor Insights | Count of ICMP flows based on source and destination IP|

### Alert Log Analysis

#### Rule Summary

|Widget Name | Type | Usage|
|------|------|------|
|Top Drop/Reject Rules | Logs Insights | Count of drop/reject rule action matches by signature ID, message, and protocol|
|Top Alert Rules | Logs Insights | Count of alert rule action matches by signature ID, message, and protocol.  Note that alert action rule matches do not also equal pass.|
|Recent Alert Log Events| Logs Insights | Recent alert log events by timestamp.  A single alert log row can be expanded to view the entire log message.|
|Top Blocked Source IPs | Logs Insights | Count of source IPs where the rule action is blocked.|
|Top Blocked Destination IPs | Logs Insights | Count of Destination IPs where the rule action was blocked.|
|Top Blocked Destination Ports | Logs Insights | Count of destination ports where the rule action was blocked.|
|Top Blocked Remote Access Ports - Telnet, SSH, RDP | Contributor Insights | Count of flows to destination port 22, 23, or 3389 where the rule action was blocked.|
|Top blocked TCP Flows | Contributor Insights | Count of TCP flows where the rule action is blocked.|
|Top blocked UDP Flows | Contributor Insights | Count of UDP flows where the rule action is blocked.|

#### HTTP & TLS

|Widget Name | Type | Usage|
|------|------|------|
|Top HTTP Host Header | Contributor Insights | Count of top HTTP hostnames where rule action is not blocked.  Using strict order, you can insert alert rules above pass rules in order to generate HTTP alert log events.  You can use this information to help identify hostnames to include in domain list rule groups or custom Suricata rules.|
|Top Blocked HTTP Host Header| Contributor Insights | Count of hostnames for blocked HTTP requests.|
|Top HTTP URI Paths | Contributor Insights | Count of URI paths seen in HTTP requests.|
|Top HTTP User-Agents | Contributor Insights | Count of user-agents seen in HTTP requests.|
|Top TLS SNI | Contributor Insights | Count of top server names where rule action is not blocked.  Using strict order, you can insert alert rules above pass rules in order to generate TLS alert log events.  You can use this information to help identify server names to include in domain list rule groups or custom Suricata rules.|
|Top Blocked SNI| Contributor Insights | Count of SNI for blocked TLS requests.|
|Top PrivateLink Endpoint Candidates (S3, DynamoDB, & Backup) | Logs Insights | Highlights HTTP/TLS calls to high throughput AWS services such as S3.  Implementing a Gateway or Interface endpoint for these services may be more cost effective than routing this traffic through AWS Network Firewall.|

## Troubleshooting

### Common Issues

1. **Dashboard widgets not showing data**
   - Ensure your firewall is actively processing traffic
   - Verify that flow and alert logging are properly configured
   - Check that the log group names are correct
   - Wait a few minutes for data to populate

2. **Contributor Insights rules not working**
   - Verify that the `contributor_insights_rule_state` is set to "ENABLED"
   - Check that log events are being published to the specified log groups
   - Ensure the log format matches the expected structure

3. **Permission errors**
   - Verify that your AWS credentials have the necessary permissions for CloudWatch, Logs, and Contributor Insights
   - Check that the Terraform execution role has appropriate permissions

### Useful Commands

```bash
# Check Terraform state
terraform show

# Validate configuration
terraform validate

# Format configuration files
terraform fmt

# Show planned changes
terraform plan

# Apply specific resources
terraform apply -target=aws_cloudwatch_dashboard.firewall_dashboard
```

## Resources

For more information about developing applications using Terraform and AWS CloudWatch, see:

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CloudWatch User Guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/)
- [AWS Network Firewall Developer Guide](https://docs.aws.amazon.com/network-firewall/latest/developerguide/)