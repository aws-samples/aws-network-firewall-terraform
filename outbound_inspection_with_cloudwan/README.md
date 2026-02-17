# Egress Inspection with AWS Cloud WAN and AWS Network Firewall

This Terraform configuration deploys a multi-region egress inspection architecture using AWS Cloud WAN and AWS Network Firewall.

## Architecture

![Base Architecture](../images/egress-inspection-aws-cloud-wan-base-architecture.png)

## Prerequisites

- AWS account with appropriate IAM permissions
- Terraform >= 1.0.0
- AWS CLI configured with credentials

## Description

This architecture demonstrates centralized egress inspection across multiple AWS regions using AWS Cloud WAN. The deployment includes:

- **AWS Cloud WAN Global Network and Core Network** - Provides global connectivity across regions
- **Production VPCs** - Workload VPCs with EC2 instances
- **Inspection VPCs** - VPCs with AWS Network Firewall for egress traffic inspection
- **Domain Allowlist** - Firewall rules allowing traffic only to specified domains

### Regional Resources

| Region | Resources |
|--------|-----------|
| us-east-1 (Region 1) | Prod VPC 1, Inspection VPC 1 |
| us-east-2 (Region 2) | Prod VPC 2, Prod VPC 4 (with local firewall) |
| us-west-2 (Region 3) | Prod VPC 3, Inspection VPC 3 |

### Traffic Flow

1. **Prod VPCs 1, 2, 3**: Egress traffic routes through Cloud WAN to regional Inspection VPCs
2. **Prod VPC 4**: Has its own local firewall for egress inspection (no Cloud WAN attachment for egress)

## Directory Structure

```
outbound_inspection_with_cloudwan/
├── main.tf                # Root module - orchestrates all modules
├── variables.tf           # Root variables
├── outputs.tf             # Root outputs
├── providers.tf           # Provider configurations for all regions
├── versions.tf            # Terraform and provider version constraints
├── modules/
│   ├── core_network/      # Global Network and Core Network
│   ├── region1/           # us-east-1 resources
│   ├── region2/           # us-east-2 resources
│   └── region3/           # us-west-2 resources
└── README.md
```

## Deployment

Deploy the entire architecture with a single command:

```bash
terraform init
terraform plan
terraform apply
```

The root module automatically:
1. Creates the Core Network first
2. Passes the Core Network ID and ARN to all regional modules
3. Deploys all regional resources with proper dependencies

### Partial Deployment

If you want to deploy only specific regions, you can use Terraform's `-target` flag to deploy individual modules:

```bash
# Deploy only the Core Network
terraform apply -target=module.core_network

# Deploy Core Network and Region 1 (us-east-1) only
terraform apply -target=module.core_network -target=module.region1

# Deploy Core Network and Regions 1 & 3 (skip Region 2)
terraform apply -target=module.core_network -target=module.region1 -target=module.region3
```

**⚠️ When deploying partial configurations, remember to update the `edge_locations` variable to only include the regions you're deploying to avoid unnecessary Core Network edge charges**

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Project name for resource naming | `cloudwan-egress` |
| `edge_locations` | List of edge locations for Core Network | `["us-east-1", "us-east-2", "us-west-2"]` |
| `instance_type` | EC2 instance type for workloads | `t2.micro` |
| `allowed_domains` | Domains allowed for egress traffic | `[".amazon.com", ".amazonaws.com", ".google.com"]` |

### Customizing Variables

Create a `terraform.tfvars` file:

```hcl
project_name    = "myproject"
instance_type   = "t3.micro"
allowed_domains = [".amazon.com", ".amazonaws.com", ".google.com", ".github.com"]
```

Or pass variables on the command line:

```bash
terraform apply -var="project_name=myproject" -var="instance_type=t3.micro"
```

## Testing

1. Connect to a workload instance using EC2 Instance Connect
2. Test allowed domains:
   ```bash
   curl https://www.amazon.com
   curl https://www.google.com
   ```
3. Test blocked domains (should fail):
   ```bash
   curl https://www.example.com
   ```

## Cleanup

Destroy all resources:

```bash
terraform destroy
```

## Outputs

After deployment, view outputs with:

```bash
terraform output
```

Key outputs include:
- Core Network ID and ARN
- VPC IDs for all Production and Inspection VPCs
- Network Firewall Endpoint IDs

## Cost Considerations

Keep the following in mind when testing this environment:

- AWS Cloud WAN core network edge (CNE) is created in each edge location
- EC2 instances are deployed in all workload subnets
- EC2 Instance Connect Endpoints are deployed in each VPC
- AWS Network Firewall endpoints are deployed in all firewall subnets
- NAT Gateways are deployed in all public subnets of inspection VPCs and Prod VPC 4

For production environments, we recommend using at least 2 AZs for high availability.

## Related Resources

- [Egress Inspection with AWS Cloud WAN and AWS Network Firewall Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/547dc923-8c8f-45b2-a772-f1c233e6864c/en-US)
- [AWS Cloud WAN Documentation](https://docs.aws.amazon.com/vpc/latest/cloudwan/)
- [AWS Network Firewall Documentation](https://docs.aws.amazon.com/network-firewall/)
