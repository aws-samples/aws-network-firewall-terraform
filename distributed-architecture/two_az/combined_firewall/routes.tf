// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Public Subnet Route Tables
resource "aws_route_table" "public_1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-route-table-1"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_1.id
}

resource "aws_route" "public_1_to_firewall" {
  route_table_id         = aws_route_table.public_1.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoint_id_az1
}

resource "aws_route_table" "public_2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-route-table-2"
  }
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_2.id
}

resource "aws_route" "public_2_to_firewall" {
  route_table_id         = aws_route_table.public_2.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoint_id_az2
}

# Firewall Subnet Route Tables
resource "aws_route_table" "firewall_1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-firewall-route-table-1"
  }
}

resource "aws_route_table_association" "firewall_1" {
  subnet_id      = aws_subnet.firewall_1.id
  route_table_id = aws_route_table.firewall_1.id
}

resource "aws_route" "firewall_1_to_igw" {
  route_table_id         = aws_route_table.firewall_1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "firewall_2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-firewall-route-table-2"
  }
}

resource "aws_route_table_association" "firewall_2" {
  subnet_id      = aws_subnet.firewall_2.id
  route_table_id = aws_route_table.firewall_2.id
}

resource "aws_route" "firewall_2_to_igw" {
  route_table_id         = aws_route_table.firewall_2.id
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

resource "aws_route" "ingress_to_public_1" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.public_subnet_1_cidr
  vpc_endpoint_id        = local.firewall_endpoint_id_az1
}

resource "aws_route" "ingress_to_public_2" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.public_subnet_2_cidr
  vpc_endpoint_id        = local.firewall_endpoint_id_az2
}
