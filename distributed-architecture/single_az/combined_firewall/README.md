# Distributed Architecture - Single AZ Combined Firewall

This Terraform configuration deploys AWS Network Firewall in a distributed model with a single firewall handling both ingress and egress traffic in one Availability Zone.

## Architecture

![Combined Firewall Single AZ](../../../images/distributed-architecture/nfw-distributed-model-combined-endpoint-1az.png)

### Traffic Flow

- **Egress:** Test Instance → Firewall → Internet Gateway → Internet
- **Ingress:** Internet → Internet Gateway → Firewall → Test Instance

## Resources Created

- VPC with public and firewall subnets
- Internet Gateway
- AWS Network Firewall with logging-only rule group
- Test EC2 instance with SSM access
- VPC Endpoints for SSM (ssm, ec2messages, ssmmessages)
- CloudWatch Log Groups for firewall flow and alert logs
- Route tables with proper routing through firewall

## Prerequisites

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- AWS provider ~> 6.31

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| aws_region | AWS Region for deployment | us-east-1 |
| availability_zone | Availability Zone for deployment | us-east-1a |
| vpc_cidr | CIDR block for the VPC | 10.2.0.0/16 |
| public_subnet_cidr | CIDR block for the public subnet | 10.2.1.0/24 |
| firewall_subnet_cidr | CIDR block for the firewall subnet | 10.2.16.0/28 |
| project_name | Name prefix for all resources | nfw-distributed-1az |

## Testing

1. Connect to the test instance using SSM Session Manager
2. Test egress connectivity: `curl checkip.amazonaws.com`
3. Review firewall logs in CloudWatch

## Cleanup

```bash
terraform destroy
```
