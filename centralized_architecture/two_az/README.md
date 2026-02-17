# Centralized Architecture - Two AZ Deployment

This Terraform configuration deploys AWS Network Firewall in a centralized architecture pattern across two Availability Zones. This configuration provides high availability and is recommended for production environments.

![Base Architecture](../../images/centralized-architecture/nfw-centralized-model-2az.png)

## Architecture Overview

This multi-AZ deployment creates a centralized inspection model using AWS Transit Gateway as the network hub. All traffic between spoke VPCs and to the Internet is routed through dedicated inspection points distributed across two Availability Zones for high availability.

## Resources Created

### Inspection VPC
Centralized VPC for both East-West (VPC to VPC) and North-South (Internet-bound) traffic inspection across two AZs:
- **Transit Gateway Subnets** - Attachment points for Transit Gateway in each AZ
- **Firewall Subnets** - Contains AWS Network Firewall endpoints in each AZ
- **Public Subnets** - Contains NAT Gateways for Internet access in each AZ

### Spoke VPCs
Two example workload VPCs that demonstrate traffic routing through the inspection points:
- Private subnets distributed across availability zones
- Route tables configured to send traffic through Transit Gateway

### AWS Network Firewall
- Firewall policy with example rules
- Firewall endpoints in the Inspection VPC across both AZs
- Logging configuration for traffic analysis
- High availability through multi-AZ deployment

### Transit Gateway
- Central routing hub connecting all VPCs
- Route tables configured to direct traffic through inspection VPC
- Appliance Mode enabled for the inspection VPC attachment to ensure flow symmetry

## Traffic Flow

1. **East-West Traffic** - VPC to VPC communication routes through the Inspection VPC firewall endpoints
2. **Egress Traffic** - Internet-bound traffic routes through the Inspection VPC firewall endpoints and NAT Gateways

## High Availability Features

- **Multi-AZ Deployment** - Resources distributed across two Availability Zones
- **AZ-Specific Routing** - Dedicated route tables ensure traffic stays within the same AZ

## Deployment Instructions

```bash
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| aws_region | AWS region for deployment | string | us-east-1 |
| availability_zones | List of Availability Zones | list(string) | ["us-east-1a", "us-east-1b"] |
| project_name | Project name used for resource naming | string | anfw-centralized |
| spoke_a_cidr | CIDR block for Spoke A VPC | string | 10.1.0.0/16 |
| spoke_b_cidr | CIDR block for Spoke B VPC | string | 10.2.0.0/16 |
| inspection_vpc_cidr | CIDR block for Inspection VPC | string | 100.64.0.0/16 |
| home_net_cidrs | CIDR blocks for HOME_NET in firewall rules | list(string) | ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] |
| log_retention_days | CloudWatch log retention in days | number | 30 |

## Outputs

| Name | Description |
|------|-------------|
| firewall_endpoint_ids | Network Firewall Endpoint IDs per AZ |
| firewall_endpoint_az1 | Network Firewall Endpoint ID for AZ1 |
| firewall_endpoint_az2 | Network Firewall Endpoint ID for AZ2 |
| transit_gateway_id | Transit Gateway ID |
| spoke_a_instance_ids | Spoke A EC2 Instance IDs |
| spoke_b_instance_ids | Spoke B EC2 Instance IDs |
| availability_zones | Availability Zones used |

## Multi-AZ Benefits

- **High Availability** - Continues operating if one AZ becomes unavailable
- **Fault Tolerance** - No single point of failure
- **Performance** - AZ-aware routing minimizes latency
- **Scalability** - Can handle higher traffic volumes across multiple AZs

## Cost Considerations

This deployment incurs higher costs compared to single AZ due to:
- Additional NAT Gateway in second AZ
- Additional firewall endpoints

## Testing Alternative

For development and testing environments, consider the [Single AZ Deployment](../single_az/) which provides the same functionality at lower cost.

## Additional Resources

- [AWS Network Firewall Documentation](https://docs.aws.amazon.com/network-firewall/)
- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/transit-gateway/)
- [Deployment models for AWS Network Firewall Blog](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall/)
