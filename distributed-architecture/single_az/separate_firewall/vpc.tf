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

# Private Subnet (EC2 instances)
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# NLB Subnet
resource "aws_subnet" "nlb" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.nlb_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-nlb-subnet"
  }
}

# NAT Gateway Subnet
resource "aws_subnet" "nat" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.nat_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-nat-subnet"
  }
}

# Ingress Firewall Subnet
resource "aws_subnet" "ingress_firewall" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.ingress_firewall_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-ingress-firewall-subnet"
  }
}

# Egress Firewall Subnet
resource "aws_subnet" "egress_firewall" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.egress_firewall_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-egress-firewall-subnet"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-natgw-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.nat.id

  tags = {
    Name = "${var.project_name}-natgw"
  }

  depends_on = [aws_internet_gateway.main]
}
