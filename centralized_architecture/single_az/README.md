# Single AZ Centralized Architecture

This Terraform configuration deploys a centralized AWS Network Firewall architecture in a single Availability Zone. This deployment is suitable for testing and proof-of-concept environments.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Transit Gateway                                │
└─────────────────────────────────────────────────────────────────────────────┘
         │                          │                          │
         ▼                          ▼                          ▼
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────────────┐
│   Spoke A VPC   │      │   Spoke B VPC   │      │    Inspection VPC       │
│   10.1.0.0/16   │      │   10.2.0.0/16   │      │    100.64.0.0/16        │
├─────────────────┤      ├─────────────────┤      ├─────────────────────────┤
│ Workload Subnet │      │ Workload Subnet │      │ TGW Subnet              │
│ TGW Subnet      │      │ TGW Subnet      │      │         ▼               │
│ SSM Endpoints   │      │ SSM Endpoints   │      │ Network Firewall        │
│ EC2 Instance    │      │ EC2 Instance    │      │         ▼               │
└─────────────────┘      └─────────────────┘      │ NAT Gateway             │
                                                  │         ▼               │
                                                  │ Internet Gateway        │
                                                  └─────────────────────────┘
```

## Resources Created

- 3 VPCs (Spoke A, Spoke B, Inspection)
- Transit Gateway with route tables
- AWS Network Firewall with logging
- NAT Gateway and Internet Gateway
- EC2 instances in spoke VPCs
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
| availability_zone | Availability Zone for deployment | string | us-east-1a |
| project_name | Project name used for resource naming | string | anfw-centralized |
| spoke_a_cidr | CIDR block for Spoke A VPC | string | 10.1.0.0/16 |
| spoke_b_cidr | CIDR block for Spoke B VPC | string | 10.2.0.0/16 |
| inspection_vpc_cidr | CIDR block for Inspection VPC | string | 100.64.0.0/16 |
| home_net_cidrs | CIDR blocks for HOME_NET in firewall rules | list(string) | ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] |
| log_retention_days | CloudWatch log retention in days | number | 30 |

## Outputs

| Name | Description |
|------|-------------|
| firewall_endpoint_id | Network Firewall Endpoint ID |
| transit_gateway_id | Transit Gateway ID |
| spoke_a_instance_id | Spoke A EC2 Instance ID |
| spoke_b_instance_id | Spoke B EC2 Instance ID |
