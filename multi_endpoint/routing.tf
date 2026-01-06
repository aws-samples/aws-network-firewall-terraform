# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# =============================================================================
# ROUTE TABLES
# =============================================================================

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-private-rt" }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# NLB Route Table
resource "aws_route_table" "nlb" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-nlb-rt" }
}

resource "aws_route_table_association" "nlb" {
  subnet_id      = aws_subnet.nlb.id
  route_table_id = aws_route_table.nlb.id
}

# Primary Firewall Route Table
resource "aws_route_table" "primary_firewall" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-primary-firewall-rt" }
}

resource "aws_route_table_association" "primary_firewall" {
  subnet_id      = aws_subnet.primary_firewall.id
  route_table_id = aws_route_table.primary_firewall.id
}

# Secondary Firewall Route Table
resource "aws_route_table" "secondary_firewall" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-secondary-firewall-rt" }
}

resource "aws_route_table_association" "secondary_firewall" {
  subnet_id      = aws_subnet.secondary_firewall.id
  route_table_id = aws_route_table.secondary_firewall.id
}

# NAT Subnet Route Table
resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-nat-rt" }
}

resource "aws_route_table_association" "nat" {
  subnet_id      = aws_subnet.nat.id
  route_table_id = aws_route_table.nat.id
}

# IGW Route Table (for ingress traffic)
resource "aws_route_table" "ingress" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-ingress-rt" }
}

resource "aws_route_table_association" "ingress" {
  route_table_id = aws_route_table.ingress.id
  gateway_id     = aws_internet_gateway.main.id
}

# =============================================================================
# STATIC ROUTES
# =============================================================================

# Primary firewall subnet -> NAT Gateway (for egress)
resource "aws_route" "primary_firewall_to_nat" {
  route_table_id         = aws_route_table.primary_firewall.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Secondary firewall subnet -> IGW (for ingress return traffic)
resource "aws_route" "secondary_firewall_to_igw" {
  route_table_id         = aws_route_table.secondary_firewall.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# NAT subnet -> IGW
resource "aws_route" "nat_default" {
  route_table_id         = aws_route_table.nat.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# =============================================================================
# FIREWALL ENDPOINT ROUTES
# =============================================================================

# Private subnet -> Primary firewall endpoint (egress)
resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.primary_endpoint_id
}

# NAT return -> Primary firewall endpoint -> Private subnet
resource "aws_route" "nat_to_private" {
  route_table_id         = aws_route_table.nat.id
  destination_cidr_block = local.private_subnet_cidr
  vpc_endpoint_id        = local.primary_endpoint_id
}

# NLB subnet -> Secondary firewall endpoint (ingress return)
resource "aws_route" "nlb_to_firewall" {
  route_table_id         = aws_route_table.nlb.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.secondary_endpoint_id
}

# IGW -> Secondary firewall endpoint -> NLB subnet (ingress)
resource "aws_route" "ingress_to_nlb" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = local.nlb_subnet_cidr
  vpc_endpoint_id        = local.secondary_endpoint_id
}
