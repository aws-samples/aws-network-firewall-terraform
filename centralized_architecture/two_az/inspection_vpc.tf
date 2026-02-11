// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#------------------------------------------------------------------------------
# Inspection VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "inspection" {
  cidr_block           = var.inspection_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "inspection-egress-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Subnets - One per AZ
#------------------------------------------------------------------------------
resource "aws_subnet" "inspection_firewall" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.inspection.id
  cidr_block              = cidrsubnet(var.inspection_vpc_cidr, 12, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "inspection-firewall-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_subnet" "inspection_tgw" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.inspection.id
  cidr_block              = cidrsubnet(var.inspection_vpc_cidr, 12, count.index + 3)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "inspection-tgw-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_subnet" "inspection_public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.inspection.id
  cidr_block              = cidrsubnet(var.inspection_vpc_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "inspection-public-${count.index + 1}-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Internet Gateway
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "inspection" {
  vpc_id = aws_vpc.inspection.id

  tags = {
    Name = "inspection-igw-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# NAT Gateways - One per AZ
#------------------------------------------------------------------------------
resource "aws_eip" "inspection_nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = {
    Name = "inspection-natgw-eip-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_nat_gateway" "inspection" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.inspection_nat[count.index].id
  subnet_id     = aws_subnet.inspection_public[count.index].id

  tags = {
    Name = "inspection-natgw-${count.index + 1}-${var.project_name}"
  }

  depends_on = [aws_internet_gateway.inspection]
}

#------------------------------------------------------------------------------
# Route Tables - Firewall subnets
#------------------------------------------------------------------------------
resource "aws_route_table" "inspection_firewall" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.inspection.id

  tags = {
    Name = "inspection-firewall-rt-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_route" "inspection_firewall_default" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.inspection_firewall[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.inspection[count.index].id
}

resource "aws_route" "inspection_firewall_internal" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.inspection_firewall[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.inspection]
}

resource "aws_route_table_association" "inspection_firewall" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.inspection_firewall[count.index].id
  route_table_id = aws_route_table.inspection_firewall[count.index].id
}

#------------------------------------------------------------------------------
# Route Tables - TGW subnets (routes through firewall)
#------------------------------------------------------------------------------
resource "aws_route_table" "inspection_tgw" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.inspection.id

  tags = {
    Name = "inspection-tgw-rt-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_route" "inspection_tgw_default" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.inspection_tgw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoint_ids[count.index]

  depends_on = [aws_networkfirewall_firewall.main]
}

resource "aws_route_table_association" "inspection_tgw" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.inspection_tgw[count.index].id
  route_table_id = aws_route_table.inspection_tgw[count.index].id
}

#------------------------------------------------------------------------------
# Route Tables - Public subnets
#------------------------------------------------------------------------------
resource "aws_route_table" "inspection_public" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.inspection.id

  tags = {
    Name = "inspection-public-rt-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_route" "inspection_public_default" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.inspection_public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection.id
}

resource "aws_route" "inspection_public_internal" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.inspection_public[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = local.firewall_endpoint_ids[count.index]

  depends_on = [aws_networkfirewall_firewall.main]
}

resource "aws_route_table_association" "inspection_public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.inspection_public[count.index].id
  route_table_id = aws_route_table.inspection_public[count.index].id
}
