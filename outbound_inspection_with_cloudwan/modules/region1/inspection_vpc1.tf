// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# ---------- Inspection VPC 1 ----------
resource "aws_vpc" "inspection_vpc1" {
  cidr_block = var.inspection_vpc1_cidr

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1"
  }
}

# ---------- Internet Gateway ----------
resource "aws_internet_gateway" "inspection_vpc1" {
  vpc_id = aws_vpc.inspection_vpc1.id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-igw"
  }
}

# ---------- Inspection VPC 1 Subnets ----------
# Cloud WAN Subnets
resource "aws_subnet" "inspection_vpc1_cwan" {
  count             = 2
  vpc_id            = aws_vpc.inspection_vpc1.id
  cidr_block        = var.inspection_vpc1_cwan_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-cwan-subnet${count.index + 1}"
  }
}

# Firewall Subnets
resource "aws_subnet" "inspection_vpc1_firewall" {
  count             = 2
  vpc_id            = aws_vpc.inspection_vpc1.id
  cidr_block        = var.inspection_vpc1_firewall_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-fwe-subnet${count.index + 1}"
  }
}

# Public Subnets
resource "aws_subnet" "inspection_vpc1_public" {
  count                   = 2
  vpc_id                  = aws_vpc.inspection_vpc1.id
  cidr_block              = var.inspection_vpc1_public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-public-subnet${count.index + 1}"
  }
}

# ---------- Inspection VPC 1 Route Tables ----------
# Cloud WAN Route Tables
resource "aws_route_table" "inspection_vpc1_cwan" {
  count  = 2
  vpc_id = aws_vpc.inspection_vpc1.id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-cwan-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "inspection_vpc1_cwan" {
  count          = 2
  subnet_id      = aws_subnet.inspection_vpc1_cwan[count.index].id
  route_table_id = aws_route_table.inspection_vpc1_cwan[count.index].id
}

# Firewall Route Tables
resource "aws_route_table" "inspection_vpc1_firewall" {
  count  = 2
  vpc_id = aws_vpc.inspection_vpc1.id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-fwe-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "inspection_vpc1_firewall" {
  count          = 2
  subnet_id      = aws_subnet.inspection_vpc1_firewall[count.index].id
  route_table_id = aws_route_table.inspection_vpc1_firewall[count.index].id
}

# Public Route Tables
resource "aws_route_table" "inspection_vpc1_public" {
  count  = 2
  vpc_id = aws_vpc.inspection_vpc1.id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-public-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "inspection_vpc1_public" {
  count          = 2
  subnet_id      = aws_subnet.inspection_vpc1_public[count.index].id
  route_table_id = aws_route_table.inspection_vpc1_public[count.index].id
}

# ---------- NAT Gateways ----------
resource "aws_eip" "inspection_vpc1_natgw" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-natgw${count.index + 1}-eip"
  }
}

resource "aws_nat_gateway" "inspection_vpc1" {
  count         = 2
  allocation_id = aws_eip.inspection_vpc1_natgw[count.index].id
  subnet_id     = aws_subnet.inspection_vpc1_public[count.index].id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc1-natgw${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.inspection_vpc1]
}

# ---------- Cloud WAN Attachment ----------
resource "aws_networkmanager_vpc_attachment" "inspection_vpc1" {
  core_network_id = var.core_network_id
  vpc_arn         = aws_vpc.inspection_vpc1.arn
  subnet_arns     = aws_subnet.inspection_vpc1_cwan[*].arn

  tags = {
    Name   = "${var.project_name}-${local.region}-insp-vpc1-attachment"
    domain = "EgressInspection"
  }
}

# ---------- Routes ----------
# CWAN route tables: default route to firewall endpoints
resource "aws_route" "inspection_vpc1_cwan_default" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc1_cwan[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.inspection_vpc1_firewall_endpoint_ids[count.index]

  depends_on = [aws_networkfirewall_firewall.inspection_vpc1]
}

# Firewall route tables: default route to NAT Gateway
resource "aws_route" "inspection_vpc1_firewall_default" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc1_firewall[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.inspection_vpc1[count.index].id
}

# Firewall route tables: summary route to Core Network
resource "aws_route" "inspection_vpc1_firewall_summary" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc1_firewall[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  core_network_arn       = var.core_network_arn

  depends_on = [aws_networkmanager_vpc_attachment.inspection_vpc1]
}

# Public route tables: default route to IGW
resource "aws_route" "inspection_vpc1_public_default" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc1_public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection_vpc1.id
}

# Public route tables: summary route to firewall endpoints
resource "aws_route" "inspection_vpc1_public_summary" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc1_public[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = local.inspection_vpc1_firewall_endpoint_ids[count.index]

  depends_on = [aws_networkfirewall_firewall.inspection_vpc1]
}
