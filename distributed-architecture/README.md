# Distributed Architecture

The distributed deployment model deploys AWS Network Firewall into each VPC that requires protection. Each VPC is protected individually, reducing blast radius through VPC isolation. This model doesn't require connectivity to other VPCs or AWS Transit Gateway, allowing independent management of each firewall.

## Available Templates

This folder contains templates organized by deployment configuration:

### [Single AZ Deployment](single_az/)
- **Use Case:** Testing and proof-of-concept environments
- **Resources:** All components deployed in a single Availability Zone
- **Templates:** Combined and separate ingress/egress firewall options

### [Two AZ Deployment](two_az/)
- **Use Case:** Environments requiring high availability
- **Resources:** Components distributed across two Availability Zones
- **Templates:** Combined and separate ingress/egress firewall options

## Template Variations

Each deployment option includes two firewall configuration approaches:

**Combined Ingress and Egress Firewall**
- Single firewall handles both inbound and outbound traffic
- Resources require public IP addresses (no NAT Gateway)
- Simplified architecture with fewer resources
- Cost-optimized for most use cases

**Separate Ingress and Egress Firewall**
- Dedicated firewalls for inbound and outbound traffic
- Resources can remain private (includes NAT Gateway)
- Network Load Balancer provides public IP for ingress to private resources

## Architecture Diagrams

### Combined Firewall - Single AZ
![Combined Firewall Single AZ](../images/distributed-architecture/nfw-distributed-model-combined-endpoint-1az.png)

### Combined Firewall - Two AZ
![Combined Firewall Two AZ](../images/distributed-architecture/nfw-distributed-model-combined-endpoint-2az.png)

### Separate Firewall - Single AZ
![Separate Firewall Single AZ](../images/distributed-architecture/nfw-distributed-model-seperate-endpoint-1az.png)

### Separate Firewall - Two AZ
![Separate Firewall Two AZ](../images/distributed-architecture/nfw-distributed-model-seperate-endpoint-2az.png)

## Architecture Benefits

- **VPC Isolation** - Each VPC protected independently
- **Reduced Blast Radius** - Misconfigurations limited to single VPC
- **Independent Management** - Each firewall managed separately
- **Policy Flexibility** - Unique policies per VPC or shared rule groups
- **No Transit Gateway Required** - Simplified network architecture

## Deployment

Each subdirectory contains a complete Terraform configuration. To deploy:

```bash
cd single_az/combined_firewall  # or your chosen configuration
terraform init
terraform plan
terraform apply
```

## Additional Resources

For detailed information about AWS Network Firewall deployment models, refer to the [AWS Blog: Deployment models for AWS Network Firewall](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall/).
