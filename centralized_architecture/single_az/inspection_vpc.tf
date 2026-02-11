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
# Subnets
#------------------------------------------------------------------------------
resource "aws_subnet" "inspection_firewall" {
  vpc_id                  = aws_vpc.inspection.id
  cidr_block              = cidrsubnet(var.inspection_vpc_cidr, 12, 1)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "inspection-firewall-${var.project_name}"
  }
}

resource "aws_subnet" "inspection_tgw" {
  vpc_id                  = aws_vpc.inspection.id
  cidr_block              = cidrsubnet(var.inspection_vpc_cidr, 12, 0)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "inspection-tgw-${var.project_name}"
  }
}

resource "aws_subnet" "inspection_public" {
  vpc_id                  = aws_vpc.inspection.id
  cidr_block              = cidrsubnet(var.inspection_vpc_cidr, 8, 1)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "inspection-public-${var.project_name}"
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
# NAT Gateway
#------------------------------------------------------------------------------
resource "aws_eip" "inspection_nat" {
  domain = "vpc"

  tags = {
    Name = "inspection-natgw-eip-${var.project_name}"
  }
}

resource "aws_nat_gateway" "inspection" {
  allocation_id = aws_eip.inspection_nat.id
  subnet_id     = aws_subnet.inspection_public.id

  tags = {
    Name = "inspection-natgw-${var.project_name}"
  }

  depends_on = [aws_internet_gateway.inspection]
}

#------------------------------------------------------------------------------
# Route Tables
#------------------------------------------------------------------------------

# Firewall subnet route table - routes to NAT for internet, TGW for internal
resource "aws_route_table" "inspection_firewall" {
  vpc_id = aws_vpc.inspection.id

  tags = {
    Name = "inspection-firewall-rt-${var.project_name}"
  }
}

resource "aws_route" "inspection_firewall_default" {
  route_table_id         = aws_route_table.inspection_firewall.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.inspection.id
}

resource "aws_route" "inspection_firewall_internal" {
  route_table_id         = aws_route_table.inspection_firewall.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.inspection]
}

resource "aws_route_table_association" "inspection_firewall" {
  subnet_id      = aws_subnet.inspection_firewall.id
  route_table_id = aws_route_table.inspection_firewall.id
}

# TGW subnet route table - routes through firewall
resource "aws_route_table" "inspection_tgw" {
  vpc_id = aws_vpc.inspection.id

  tags = {
    Name = "inspection-tgw-rt-${var.project_name}"
  }
}

resource "aws_route" "inspection_tgw_default" {
  route_table_id         = aws_route_table.inspection_tgw.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoint_id

  depends_on = [aws_networkfirewall_firewall.main]
}

resource "aws_route_table_association" "inspection_tgw" {
  subnet_id      = aws_subnet.inspection_tgw.id
  route_table_id = aws_route_table.inspection_tgw.id
}

# Public subnet route table - routes to IGW for internet, firewall for internal
resource "aws_route_table" "inspection_public" {
  vpc_id = aws_vpc.inspection.id

  tags = {
    Name = "inspection-public-rt-${var.project_name}"
  }
}

resource "aws_route" "inspection_public_default" {
  route_table_id         = aws_route_table.inspection_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection.id
}

resource "aws_route" "inspection_public_internal" {
  route_table_id         = aws_route_table.inspection_public.id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = local.firewall_endpoint_id

  depends_on = [aws_networkfirewall_firewall.main]
}

resource "aws_route_table_association" "inspection_public" {
  subnet_id      = aws_subnet.inspection_public.id
  route_table_id = aws_route_table.inspection_public.id
}
