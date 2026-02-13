# Pre-Deployed Transit Gateway-Attached Firewall

This Terraform configuration provides a fully automated deployment of AWS Network Firewall with native Transit Gateway attachment. The complete infrastructure is deployed with firewall attachment and routing pre-configured for immediate use.

![Full Deployment Architecture](../../images/transit-gateway-attached-firewall/tgw-native-attach-full.png)

## Architecture Overview

This deployment demonstrates the Transit Gateway native attachment capability, where AWS Network Firewall attaches directly to Transit Gateway as a network function. This eliminates the need for manual setup of a dedicated inspection VPC, Network Firewall deployment within it, and complex subnet routing, while providing centralized inspection.

## Resources Created

### Transit Gateway
Central routing hub connecting all VPCs with three route tables:
- **Spoke Route Table** - Associated with spoke VPC attachments, routes all traffic to firewall attachment
- **Inspection Route Table** - Associated with firewall attachment, routes to egress VPC or spoke VPCs
- **Egress Route Table** - Associated with egress VPC attachment, routes all traffic to firewall attachment

### AWS Network Firewall
Network Firewall with Transit Gateway native attachment:
- Firewall with Transit Gateway attachment (network function)
- Stateful rule groups with egress allow-list and logging rules
- CloudWatch logging for flow and alert logs

### Spoke VPCs (Spoke A and Spoke B)
Two example workload VPCs demonstrating traffic patterns:
- Workload subnets with EC2 instances
- Transit Gateway attachment subnets
- VPC endpoints for SSM access
- Route tables directing traffic to Transit Gateway

### Egress VPC
Centralized VPC providing internet access:
- **Public Subnet** - Contains NAT Gateway
- **Transit Gateway Subnet** - Attachment point for Transit Gateway

## Traffic Flow

**East-West Traffic (Spoke to Spoke)**
1. Traffic originates from Spoke VPC workload
2. VPC route table sends traffic to Transit Gateway
3. Spoke route table directs traffic to Network Firewall attachment
4. Firewall inspects traffic and returns to Transit Gateway
5. Transit Gateway forwards to destination Spoke VPC

**Egress Traffic (Internet-bound)**
1. Traffic originates from Spoke VPC workload
2. VPC route table sends traffic to Transit Gateway
3. Spoke route table directs traffic to Network Firewall attachment
4. Firewall inspects traffic and forwards traffic back to Transit Gateway
5. Inspection route table sends traffic to Egress VPC
6. NAT Gateway in Egress VPC provides internet access via Internet Gateway

## Deployment Instructions

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Post-Deployment

After deployment completes:
1. Connect to EC2 instances via AWS Systems Manager Session Manager
2. Test East-West connectivity between spoke VPCs
3. Test egress connectivity to the internet
4. Review CloudWatch logs for traffic inspection events
5. Customize firewall rules based on security requirements

## Variables

| Name | Description | Default |
|------|-------------|---------|
| aws_region | AWS region for deployment | us-east-1 |
| project_name | Project name for resource naming | tgw-attached-fw |
| availability_zone | Availability Zone for deployment | us-east-1a |
| spoke_a_vpc_cidr | CIDR for Spoke A VPC | 10.1.0.0/16 |
| spoke_b_vpc_cidr | CIDR for Spoke B VPC | 10.2.0.0/16 |
| egress_vpc_cidr | CIDR for Egress VPC | 100.64.0.0/16 |
| log_retention_days | CloudWatch log retention | 30 |
| home_net_cidrs | HOME_NET CIDRs for firewall policy | ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] |

## Outputs

| Name | Description |
|------|-------------|
| transit_gateway_id | Transit Gateway ID |
| spoke_a_instance_id | Spoke A EC2 Instance ID for testing |
| spoke_a_security_group_id | Spoke A Security Group ID |
| spoke_b_security_group_id | Spoke B Security Group ID |
| egress_tgw_route_table_id | Egress TGW Subnet Route Table ID |
| egress_public_route_table_id | Egress Public Subnet Route Table ID |
| tgw_egress_route_table_id | TGW Egress Route Table ID |
| egress_vpc_attachment_id | Egress VPC TGW Attachment ID |
| firewall_arn | Network Firewall ARN |
| firewall_tgw_attachment_id | Firewall TGW Attachment ID |

## Important Notes

- **Single AZ Deployment** - This configuration deploys resources in a single Availability Zone for simplicity and cost optimization
- **Appliance Mode** - Automatically enabled for transit gateway-attached firewalls to ensure flow symmetry

## Additional Resources

- [AWS Network Firewall Documentation](https://docs.aws.amazon.com/network-firewall/)
- [AWS Network Firewall Best Practices Guide](https://aws.github.io/aws-security-services-best-practices/guides/network-firewall/)
- [Transit Gateway-Attached Firewalls](https://docs.aws.amazon.com/network-firewall/latest/developerguide/tgw-firewall.html)
- [Deployment models for AWS Network Firewall Blog](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall/)
