// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Private Subnets
resource "aws_subnet" "private_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_az1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet-az1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_az2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet-az2"
  }
}

# NLB Subnets
resource "aws_subnet" "nlb_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.nlb_subnet_az1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-nlb-subnet-az1"
  }
}

resource "aws_subnet" "nlb_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.nlb_subnet_az2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-nlb-subnet-az2"
  }
}

# NAT Gateway Subnets
resource "aws_subnet" "nat_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.nat_subnet_az1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-nat-subnet-az1"
  }
}

resource "aws_subnet" "nat_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.nat_subnet_az2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-nat-subnet-az2"
  }
}

# Ingress Firewall Subnets
resource "aws_subnet" "ingress_firewall_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.ingress_firewall_subnet_az1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-ingress-firewall-subnet-az1"
  }
}

resource "aws_subnet" "ingress_firewall_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.ingress_firewall_subnet_az2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-ingress-firewall-subnet-az2"
  }
}

# Egress Firewall Subnets
resource "aws_subnet" "egress_firewall_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.egress_firewall_subnet_az1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-egress-firewall-subnet-az1"
  }
}

resource "aws_subnet" "egress_firewall_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.egress_firewall_subnet_az2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-egress-firewall-subnet-az2"
  }
}

# NAT Gateways
resource "aws_eip" "nat_az1" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-natgw-eip-az1"
  }
}

resource "aws_nat_gateway" "az1" {
  allocation_id = aws_eip.nat_az1.id
  subnet_id     = aws_subnet.nat_az1.id

  tags = {
    Name = "${var.project_name}-natgw-az1"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "nat_az2" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-natgw-eip-az2"
  }
}

resource "aws_nat_gateway" "az2" {
  allocation_id = aws_eip.nat_az2.id
  subnet_id     = aws_subnet.nat_az2.id

  tags = {
    Name = "${var.project_name}-natgw-az2"
  }

  depends_on = [aws_internet_gateway.main]
}
