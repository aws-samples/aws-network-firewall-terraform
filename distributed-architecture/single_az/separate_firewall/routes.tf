// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Private Subnet Route Table - Egress traffic goes through egress firewall
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "private_to_egress_firewall" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.egress_firewall_endpoint_id
}

# NLB Subnet Route Table - Return traffic goes back through ingress firewall
resource "aws_route_table" "nlb" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-nlb-rt"
  }
}

resource "aws_route_table_association" "nlb" {
  subnet_id      = aws_subnet.nlb.id
  route_table_id = aws_route_table.nlb.id
}

resource "aws_route" "nlb_to_ingress_firewall" {
  route_table_id         = aws_route_table.nlb.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.ingress_firewall_endpoint_id
}

# NAT Subnet Route Table - Direct to IGW for internet
resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-nat-rt"
  }
}

resource "aws_route_table_association" "nat" {
  subnet_id      = aws_subnet.nat.id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route" "nat_to_igw" {
  route_table_id         = aws_route_table.nat.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Route private subnet traffic back through egress firewall (critical for return traffic)
resource "aws_route" "nat_to_private" {
  route_table_id         = aws_route_table.nat.id
  destination_cidr_block = var.private_subnet_cidr
  vpc_endpoint_id        = local.egress_firewall_endpoint_id
}

# Ingress Firewall Subnet Route Table
resource "aws_route_table" "ingress_firewall" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ingress-firewall-rt"
  }
}

resource "aws_route_table_association" "ingress_firewall" {
  subnet_id      = aws_subnet.ingress_firewall.id
  route_table_id = aws_route_table.ingress_firewall.id
}

resource "aws_route" "ingress_firewall_to_igw" {
  route_table_id         = aws_route_table.ingress_firewall.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Egress Firewall Subnet Route Table
resource "aws_route_table" "egress_firewall" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-egress-firewall-rt"
  }
}

resource "aws_route_table_association" "egress_firewall" {
  subnet_id      = aws_subnet.egress_firewall.id
  route_table_id = aws_route_table.egress_firewall.id
}

resource "aws_route" "egress_firewall_to_nat" {
  route_table_id         = aws_route_table.egress_firewall.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Internet Gateway Route Table - Ingress traffic routing
resource "aws_route_table" "ingress" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ingress-rt"
  }
}

resource "aws_route_table_association" "ingress" {
  gateway_id     = aws_internet_gateway.main.id
  route_table_id = aws_route_table.ingress.id
}

# Route ingress traffic to NLB subnet through ingress firewall
resource "aws_route" "ingress_to_nlb" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.nlb_subnet_cidr
  vpc_endpoint_id        = local.ingress_firewall_endpoint_id
}

# Route ingress traffic to private subnet through ingress firewall
resource "aws_route" "ingress_to_private" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.private_subnet_cidr
  vpc_endpoint_id        = local.ingress_firewall_endpoint_id
}
