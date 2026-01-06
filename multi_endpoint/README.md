# AWS Network Firewall Multi-Endpoint Architecture

Terraform configuration for deploying AWS Network Firewall with multiple endpoints for combined ingress/egress inspection architectures.

## Overview

This Terraform configuration addresses a critical challenge in AWS Network Firewall deployments: maintaining source IP visibility when inspecting both ingress and egress traffic within the same VPC via multiple AWS Network Firewall endpoints. 

**The Problem**: Traditional on-premises firewalls handle source NAT (SNAT) and destination NAT (DNAT) on the same appliance, preserving source IP visibility. On AWS, inspection is decoupled from NAT functions - NAT Gateways handle SNAT for egress, and Elastic Load Balancers handle DNAT for ingress. This separation can mask source IPs during inspection.

**The Solution**: Deploy **two firewall endpoints per availability zone** using AWS Network Firewall's multiple VPC endpoints feature. This architecture ensures:

- **Ingress inspection** occurs BEFORE ELB destination NAT (preserving client source IPs)
- **Egress inspection** occurs BEFORE NAT Gateway source NAT (preserving internal source IPs)  
- **Single firewall** with multiple endpoints vs. deploying separate firewalls (cost optimization)
- **Proper traffic separation** through dedicated subnets and route tables

This represents a significant improvement over previous approaches that either sacrificed source IP visibility or required complex dual-firewall architectures. The multiple endpoints feature enables both cost efficiency and security visibility in a single deployment.

### Architecture

![Multi-Endpoint Network Firewall Architecture](../images/DistributedSeparate1AZArch.png)

**Traffic Separation:**
- **Primary Endpoint**: Handles traffic going OUT from your private instances to the internet (egress inspection)
- **Secondary Endpoint**: Handles traffic coming IN from the internet to your services (ingress inspection)

## Important Notes

### Native Terraform Support
This configuration now uses the native `aws_networkfirewall_vpc_endpoint_association` Terraform resource for creating secondary endpoints. This provides:

1. **Full Terraform Management**: No need for AWS CLI or external scripts
2. **Proper State Management**: Terraform tracks the resource lifecycle
3. **Clean Dependencies**: Native resource dependencies and ordering
4. **Reliable Cleanup**: Automatic resource cleanup on destroy

### Network Load Balancer
The Network Load Balancer (NLB) doesn't use security groups in the traditional sense. Traffic filtering is handled by the Network Firewall and instance-level security groups.

### Region Compatibility
This configuration uses `data.aws_region.current.id` to dynamically determine the current AWS region for VPC endpoint service names.

## Source IP Visibility Architecture

This configuration follows AWS best practices for maintaining source IP visibility in combined ingress/egress inspection:

- **Ingress inspection** inbound from Internet via secondary firewall endpoint
- **Egress inspection** outbound from private instances via primary firewall endpoint
- **Separate endpoints** ensures all traffic flows through the firewall in the correct direction and makes the traffic paths more predictable
- **Route separation** ensures proper traffic flow through designated SSM VPC endpoints so private instances can communicate with AWS Systems Manager without going through the internet

## Quick Start

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- An AWS account with Network Firewall service available in your region

### Deploy
```bash
# Clone the repository
git clone <repository-url>
cd aws-network-firewall-terraform/multi-endpoint

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `availability_zone` | Availability Zone for deployment | `string` | First available AZ |
| `vpc_cidr` | CIDR block for the VPC (all subnets calculated automatically) | `string` | `10.2.0.0/16` |
| `project_name` | Name prefix for all resources | `string` | `nfw-multi-endpoint` |
| `instance_type` | EC2 instance type | `string` | `t3.micro` |

**Note**: All subnet CIDRs are automatically calculated from the VPC CIDR using Terraform's `cidrsubnet()` function:
- Private subnet: `10.2.1.0/24`
- NLB subnet: `10.2.2.0/24`
- Primary firewall subnet: `10.2.15.0/28`
- Secondary firewall subnet: `10.2.17.0/28`
- NAT subnet: `10.2.16.0/28`

### Outputs

- `vpc_id` - VPC ID
- `multi_endpoint_network_firewall_id` - Multi-Endpoint Network Firewall ID
- `primary_firewall_endpoint_id` - Primary Network Firewall Endpoint ID
- `secondary_firewall_endpoint_id` - Secondary Network Firewall Endpoint ID
- `network_load_balancer_dns` - Network Load Balancer DNS Name
- `private_instance_id` - Private EC2 Instance ID
- `ssm_endpoint_id` - SSM VPC Endpoint ID

### Clean Up
```bash
terraform destroy
```

## References

- [Creating a VPC endpoint association in AWS Network Firewall](https://docs.aws.amazon.com/network-firewall/latest/developerguide/creating-vpc-endpoint-association.html)
- [Source IP Visibility for Combined Ingress/Egress Inspection](https://repost.aws/articles/ARYy1Pfr4BQOGvxntapZBgSQ/source-ip-visibility-for-combined-ingress-and-egress-inspection-architectures)