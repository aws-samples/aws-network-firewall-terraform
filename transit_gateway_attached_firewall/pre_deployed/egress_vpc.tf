// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#------------------------------------------------------------------------------
# Egress VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "egress" {
  cidr_block           = var.egress_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "egress-${var.project_name}"
  }
}

resource "aws_subnet" "egress_tgw" {
  vpc_id                  = aws_vpc.egress.id
  cidr_block              = cidrsubnet(var.egress_vpc_cidr, 12, 0)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "egress-tgw-attachment-${var.project_name}"
  }
}

resource "aws_subnet" "egress_public" {
  vpc_id                  = aws_vpc.egress.id
  cidr_block              = cidrsubnet(var.egress_vpc_cidr, 8, 1)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "egress-public-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Internet Gateway
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "egress" {
  vpc_id = aws_vpc.egress.id

  tags = {
    Name = "egress-igw-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# NAT Gateway
#------------------------------------------------------------------------------
resource "aws_eip" "egress_nat" {
  domain = "vpc"

  tags = {
    Name = "egress-nat-eip-${var.project_name}"
  }
}


resource "aws_nat_gateway" "egress" {
  allocation_id = aws_eip.egress_nat.id
  subnet_id     = aws_subnet.egress_public.id

  tags = {
    Name = "egress-natgw-${var.project_name}"
  }

  depends_on = [aws_internet_gateway.egress]
}

#------------------------------------------------------------------------------
# Egress VPC Route Tables
#------------------------------------------------------------------------------
resource "aws_route_table" "egress_tgw" {
  vpc_id = aws_vpc.egress.id

  tags = {
    Name = "egress-tgw-attachment-rt-${var.project_name}"
  }
}

resource "aws_route_table_association" "egress_tgw" {
  subnet_id      = aws_subnet.egress_tgw.id
  route_table_id = aws_route_table.egress_tgw.id
}

resource "aws_route" "egress_tgw_default" {
  route_table_id         = aws_route_table.egress_tgw.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.egress.id
}

resource "aws_route_table" "egress_public" {
  vpc_id = aws_vpc.egress.id

  tags = {
    Name = "egress-public-rt-${var.project_name}"
  }
}

resource "aws_route_table_association" "egress_public" {
  subnet_id      = aws_subnet.egress_public.id
  route_table_id = aws_route_table.egress_public.id
}

resource "aws_route" "egress_public_default" {
  route_table_id         = aws_route_table.egress_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.egress.id
}

resource "aws_route" "egress_public_corp" {
  route_table_id         = aws_route_table.egress_public.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.egress]
}
