# Centralized Architecture

The centralized deployment model uses [AWS Transit Gateway](https://aws.amazon.com/transit-gateway/) as a network hub to simplify connectivity between VPCs and on-premises networks. This architecture provides centralized inspection for both East-West (VPC to VPC) and egress (internet-bound) traffic through a dedicated inspection VPC.

## Available Deployments

This folder contains Terraform configurations that deploy the centralized architecture pattern:

### [Single AZ Deployment](single_az/)
- **Use Case:** Testing and proof-of-concept environments
- **Resources:** All components deployed in a single Availability Zone

### [Two AZ Deployment](two_az/)
- **Use Case:** Production environments requiring high availability
- **Resources:** Components distributed across two Availability Zones

## Architecture Components

Both deployments create:

**Inspection VPC** - Centralized VPC for both East-West and Egress traffic inspection
- Transit Gateway subnet
- Firewall subnet (contains AWS Network Firewall endpoints)
- Public subnet (contains NAT Gateway(s) for Internet access)

**Spoke VPCs** - Example workload VPCs that route traffic through the inspection VPC
- Spoke A VPC (10.1.0.0/16)
- Spoke B VPC (10.2.0.0/16)

## Usage

```bash
# Navigate to the desired deployment
cd single_az/  # or two_az/

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Additional Resources

For detailed information about AWS Network Firewall deployment models, refer to the [AWS Blog: Deployment models for AWS Network Firewall](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall/).
