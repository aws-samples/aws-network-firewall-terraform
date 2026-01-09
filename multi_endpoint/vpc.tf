# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

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

# NAT Gateway EIP
resource "aws_eip" "nat_gateway" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-natgw-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.nat.id

  tags = {
    Name = "${var.project_name}-natgw"
  }

  depends_on = [aws_internet_gateway.main]
}

# Subnets
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_subnet_cidr
  availability_zone       = local.selected_az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

resource "aws_subnet" "nlb" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.nlb_subnet_cidr
  availability_zone       = local.selected_az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-nlb-subnet"
  }
}

resource "aws_subnet" "nat" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.nat_subnet_cidr
  availability_zone       = local.selected_az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-nat-subnet"
  }
}

resource "aws_subnet" "primary_firewall" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.primary_firewall_subnet_cidr
  availability_zone       = local.selected_az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-primary-firewall-subnet"
  }
}

resource "aws_subnet" "secondary_firewall" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.secondary_firewall_subnet_cidr
  availability_zone       = local.selected_az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-secondary-firewall-subnet"
  }
}