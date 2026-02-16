// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Private Subnet Route Tables - Egress traffic goes through egress firewall
resource "aws_route_table" "private_az1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt-az1"
  }
}

resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private_az1.id
}

resource "aws_route" "private_az1_to_egress_firewall" {
  route_table_id         = aws_route_table.private_az1.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.egress_firewall_endpoint_id_az1
}

resource "aws_route_table" "private_az2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt-az2"
  }
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.private_az2.id
}

resource "aws_route" "private_az2_to_egress_firewall" {
  route_table_id         = aws_route_table.private_az2.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.egress_firewall_endpoint_id_az2
}

# NLB Subnet Route Tables - Return traffic goes back through ingress firewall
resource "aws_route_table" "nlb_az1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-nlb-rt-az1"
  }
}

resource "aws_route_table_association" "nlb_az1" {
  subnet_id      = aws_subnet.nlb_az1.id
  route_table_id = aws_route_table.nlb_az1.id
}

resource "aws_route" "nlb_az1_to_ingress_firewall" {
  route_table_id         = aws_route_table.nlb_az1.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.ingress_firewall_endpoint_id_az1
}

resource "aws_route_table" "nlb_az2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-nlb-rt-az2"
  }
}

resource "aws_route_table_association" "nlb_az2" {
  subnet_id      = aws_subnet.nlb_az2.id
  route_table_id = aws_route_table.nlb_az2.id
}

resource "aws_route" "nlb_az2_to_ingress_firewall" {
  route_table_id         = aws_route_table.nlb_az2.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.ingress_firewall_endpoint_id_az2
}

# NAT Subnet Route Tables - Direct to IGW for internet
resource "aws_route_table" "nat_az1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-nat-rt-az1"
  }
}

resource "aws_route_table_association" "nat_az1" {
  subnet_id      = aws_subnet.nat_az1.id
  route_table_id = aws_route_table.nat_az1.id
}

resource "aws_route" "nat_az1_to_igw" {
  route_table_id         = aws_route_table.nat_az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "nat_az1_to_private" {
  route_table_id         = aws_route_table.nat_az1.id
  destination_cidr_block = var.private_subnet_az1_cidr
  vpc_endpoint_id        = local.egress_firewall_endpoint_id_az1
}

resource "aws_route_table" "nat_az2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-nat-rt-az2"
  }
}

resource "aws_route_table_association" "nat_az2" {
  subnet_id      = aws_subnet.nat_az2.id
  route_table_id = aws_route_table.nat_az2.id
}

resource "aws_route" "nat_az2_to_igw" {
  route_table_id         = aws_route_table.nat_az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "nat_az2_to_private" {
  route_table_id         = aws_route_table.nat_az2.id
  destination_cidr_block = var.private_subnet_az2_cidr
  vpc_endpoint_id        = local.egress_firewall_endpoint_id_az2
}

# Ingress Firewall Subnet Route Tables
resource "aws_route_table" "ingress_firewall_az1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ingress-firewall-rt-az1"
  }
}

resource "aws_route_table_association" "ingress_firewall_az1" {
  subnet_id      = aws_subnet.ingress_firewall_az1.id
  route_table_id = aws_route_table.ingress_firewall_az1.id
}

resource "aws_route" "ingress_firewall_az1_to_igw" {
  route_table_id         = aws_route_table.ingress_firewall_az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "ingress_firewall_az2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ingress-firewall-rt-az2"
  }
}

resource "aws_route_table_association" "ingress_firewall_az2" {
  subnet_id      = aws_subnet.ingress_firewall_az2.id
  route_table_id = aws_route_table.ingress_firewall_az2.id
}

resource "aws_route" "ingress_firewall_az2_to_igw" {
  route_table_id         = aws_route_table.ingress_firewall_az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Egress Firewall Subnet Route Tables
resource "aws_route_table" "egress_firewall_az1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-egress-firewall-rt-az1"
  }
}

resource "aws_route_table_association" "egress_firewall_az1" {
  subnet_id      = aws_subnet.egress_firewall_az1.id
  route_table_id = aws_route_table.egress_firewall_az1.id
}

resource "aws_route" "egress_firewall_az1_to_nat" {
  route_table_id         = aws_route_table.egress_firewall_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az1.id
}

resource "aws_route_table" "egress_firewall_az2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-egress-firewall-rt-az2"
  }
}

resource "aws_route_table_association" "egress_firewall_az2" {
  subnet_id      = aws_subnet.egress_firewall_az2.id
  route_table_id = aws_route_table.egress_firewall_az2.id
}

resource "aws_route" "egress_firewall_az2_to_nat" {
  route_table_id         = aws_route_table.egress_firewall_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az2.id
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

# Route ingress traffic to NLB subnets through ingress firewall
resource "aws_route" "ingress_to_nlb_az1" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.nlb_subnet_az1_cidr
  vpc_endpoint_id        = local.ingress_firewall_endpoint_id_az1
}

resource "aws_route" "ingress_to_nlb_az2" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.nlb_subnet_az2_cidr
  vpc_endpoint_id        = local.ingress_firewall_endpoint_id_az2
}

# Route ingress traffic to private subnets through ingress firewall
resource "aws_route" "ingress_to_private_az1" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.private_subnet_az1_cidr
  vpc_endpoint_id        = local.ingress_firewall_endpoint_id_az1
}

resource "aws_route" "ingress_to_private_az2" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.private_subnet_az2_cidr
  vpc_endpoint_id        = local.ingress_firewall_endpoint_id_az2
}
