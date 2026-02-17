// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# ---------- Inspection VPC 3 ----------
resource "aws_vpc" "inspection_vpc3" {
  cidr_block = var.inspection_vpc3_cidr

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3"
  }
}

# ---------- Internet Gateway ----------
resource "aws_internet_gateway" "inspection_vpc3" {
  vpc_id = aws_vpc.inspection_vpc3.id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3-igw"
  }
}

# ---------- Inspection VPC 3 Subnets ----------
# Cloud WAN Subnets
resource "aws_subnet" "inspection_vpc3_cwan" {
  count             = 2
  vpc_id            = aws_vpc.inspection_vpc3.id
  cidr_block        = var.inspection_vpc3_cwan_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3-cwan-subnet${count.index + 1}"
  }
}

# Firewall Subnets
resource "aws_subnet" "inspection_vpc3_firewall" {
  count             = 2
  vpc_id            = aws_vpc.inspection_vpc3.id
  cidr_block        = var.inspection_vpc3_firewall_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3-fwe-subnet${count.index + 1}"
  }
}

# Public Subnets
resource "aws_subnet" "inspection_vpc3_public" {
  count                   = 2
  vpc_id                  = aws_vpc.inspection_vpc3.id
  cidr_block              = var.inspection_vpc3_public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3-public-subnet${count.index + 1}"
  }
}

# ---------- Inspection VPC 3 Route Tables ----------
# Cloud WAN Route Tables
resource "aws_route_table" "inspection_vpc3_cwan" {
  count  = 2
  vpc_id = aws_vpc.inspection_vpc3.id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3-cwan-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "inspection_vpc3_cwan" {
  count          = 2
  subnet_id      = aws_subnet.inspection_vpc3_cwan[count.index].id
  route_table_id = aws_route_table.inspection_vpc3_cwan[count.index].id
}

# Firewall Route Tables
resource "aws_route_table" "inspection_vpc3_firewall" {
  count  = 2
  vpc_id = aws_vpc.inspection_vpc3.id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3-fwe-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "inspection_vpc3_firewall" {
  count          = 2
  subnet_id      = aws_subnet.inspection_vpc3_firewall[count.index].id
  route_table_id = aws_route_table.inspection_vpc3_firewall[count.index].id
}

# Public Route Tables
resource "aws_route_table" "inspection_vpc3_public" {
  count  = 2
  vpc_id = aws_vpc.inspection_vpc3.id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3-public-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "inspection_vpc3_public" {
  count          = 2
  subnet_id      = aws_subnet.inspection_vpc3_public[count.index].id
  route_table_id = aws_route_table.inspection_vpc3_public[count.index].id
}

# ---------- NAT Gateways ----------
resource "aws_eip" "inspection_vpc3_natgw" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3-natgw${count.index + 1}-eip"
  }
}

resource "aws_nat_gateway" "inspection_vpc3" {
  count         = 2
  allocation_id = aws_eip.inspection_vpc3_natgw[count.index].id
  subnet_id     = aws_subnet.inspection_vpc3_public[count.index].id

  tags = {
    Name = "${var.project_name}-${local.region}-insp-vpc3-natgw${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.inspection_vpc3]
}

# ---------- Cloud WAN Attachment ----------
resource "aws_networkmanager_vpc_attachment" "inspection_vpc3" {
  core_network_id = var.core_network_id
  vpc_arn         = aws_vpc.inspection_vpc3.arn
  subnet_arns     = aws_subnet.inspection_vpc3_cwan[*].arn

  tags = {
    Name   = "${var.project_name}-${local.region}-insp-vpc3-attachment"
    domain = "EgressInspection"
  }
}

# ---------- Routes ----------
# CWAN route tables: default route to firewall endpoints
resource "aws_route" "inspection_vpc3_cwan_default" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc3_cwan[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.inspection_vpc3_firewall_endpoint_ids[count.index]

  depends_on = [aws_networkfirewall_firewall.inspection_vpc3]
}

# Firewall route tables: default route to NAT Gateway
resource "aws_route" "inspection_vpc3_firewall_default" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc3_firewall[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.inspection_vpc3[count.index].id
}

# Firewall route tables: summary route to Core Network
resource "aws_route" "inspection_vpc3_firewall_summary" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc3_firewall[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  core_network_arn       = var.core_network_arn

  depends_on = [aws_networkmanager_vpc_attachment.inspection_vpc3]
}

# Public route tables: default route to IGW
resource "aws_route" "inspection_vpc3_public_default" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc3_public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection_vpc3.id
}

# Public route tables: summary route to firewall endpoints
resource "aws_route" "inspection_vpc3_public_summary" {
  count                  = 2
  route_table_id         = aws_route_table.inspection_vpc3_public[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = local.inspection_vpc3_firewall_endpoint_ids[count.index]

  depends_on = [aws_networkfirewall_firewall.inspection_vpc3]
}
