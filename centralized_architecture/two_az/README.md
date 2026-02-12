# Two AZ Centralized Architecture

This Terraform configuration deploys a highly available centralized AWS Network Firewall architecture across two Availability Zones. This deployment is suitable for production environments.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Transit Gateway                                 │
└─────────────────────────────────────────────────────────────────────────────┘
         │                          │                          │
         ▼                          ▼                          ▼
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────────────┐
│   Spoke A VPC   │      │   Spoke B VPC   │      │    Inspection VPC       │
│   10.1.0.0/16   │      │   10.2.0.0/16   │      │    100.64.0.0/16        │
├─────────────────┤      ├─────────────────┤      ├─────────────────────────┤
│ AZ1: Workload   │      │ AZ1: Workload   │      │ AZ1: TGW → FW → NAT     │
│ AZ2: Workload   │      │ AZ2: Workload   │      │ AZ2: TGW → FW → NAT     │
│ TGW Subnets x2  │      │ TGW Subnets x2  │      │         ▼               │
│ SSM Endpoints   │      │ SSM Endpoints   │      │ Internet Gateway        │
│ EC2 x2          │      │ EC2 x2          │      └─────────────────────────┘
└─────────────────┘      └─────────────────┘
```

## Resources Created

- 3 VPCs (Spoke A, Spoke B, Inspection)
- Transit Gateway with route tables and appliance mode
- AWS Network Firewall with endpoints in 2 AZs
- 2 NAT Gateways (one per AZ)
- Internet Gateway
- 4 EC2 instances (2 per spoke VPC)
- VPC Endpoints for SSM access
- IAM roles for EC2 instances
- CloudWatch Log Groups for firewall logs

## Usage

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
