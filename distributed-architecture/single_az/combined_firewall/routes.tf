// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Public Subnet Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_to_firewall" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoint_id
}

# Firewall Subnet Route Table
resource "aws_route_table" "firewall" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-firewall-route-table"
  }
}

resource "aws_route_table_association" "firewall" {
  subnet_id      = aws_subnet.firewall.id
  route_table_id = aws_route_table.firewall.id
}

resource "aws_route" "firewall_to_igw" {
  route_table_id         = aws_route_table.firewall.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Ingress Route Table (attached to IGW)
resource "aws_route_table" "ingress" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ingress-route-table"
  }
}

resource "aws_route_table_association" "ingress" {
  gateway_id     = aws_internet_gateway.main.id
  route_table_id = aws_route_table.ingress.id
}

resource "aws_route" "ingress_to_public" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.public_subnet_cidr
  vpc_endpoint_id        = local.firewall_endpoint_id
}
