// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#------------------------------------------------------------------------------
# Spoke A VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "spoke_a" {
  cidr_block           = var.spoke_a_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "spoke-a-${var.project_name}"
  }
}

resource "aws_subnet" "spoke_a_workload" {
  vpc_id                  = aws_vpc.spoke_a.id
  cidr_block              = cidrsubnet(var.spoke_a_vpc_cidr, 8, 1)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "spoke-a-workload-${var.project_name}"
  }
}

resource "aws_subnet" "spoke_a_tgw" {
  vpc_id                  = aws_vpc.spoke_a.id
  cidr_block              = cidrsubnet(var.spoke_a_vpc_cidr, 12, 0)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "spoke-a-tgw-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Spoke A Route Tables
#------------------------------------------------------------------------------
resource "aws_route_table" "spoke_a_workload" {
  vpc_id = aws_vpc.spoke_a.id

  tags = {
    Name = "spoke-a-workload-rt-${var.project_name}"
  }
}

resource "aws_route_table_association" "spoke_a_workload" {
  subnet_id      = aws_subnet.spoke_a_workload.id
  route_table_id = aws_route_table.spoke_a_workload.id
}


resource "aws_route" "spoke_a_workload_default" {
  route_table_id         = aws_route_table.spoke_a_workload.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.spoke_a]
}

resource "aws_route_table" "spoke_a_tgw" {
  vpc_id = aws_vpc.spoke_a.id

  tags = {
    Name = "spoke-a-tgw-rt-${var.project_name}"
  }
}

resource "aws_route_table_association" "spoke_a_tgw" {
  subnet_id      = aws_subnet.spoke_a_tgw.id
  route_table_id = aws_route_table.spoke_a_tgw.id
}

#------------------------------------------------------------------------------
# Spoke B VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "spoke_b" {
  cidr_block           = var.spoke_b_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "spoke-b-${var.project_name}"
  }
}

resource "aws_subnet" "spoke_b_workload" {
  vpc_id                  = aws_vpc.spoke_b.id
  cidr_block              = cidrsubnet(var.spoke_b_vpc_cidr, 8, 1)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "spoke-b-workload-${var.project_name}"
  }
}

resource "aws_subnet" "spoke_b_tgw" {
  vpc_id                  = aws_vpc.spoke_b.id
  cidr_block              = cidrsubnet(var.spoke_b_vpc_cidr, 12, 0)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "spoke-b-tgw-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Spoke B Route Tables
#------------------------------------------------------------------------------
resource "aws_route_table" "spoke_b_workload" {
  vpc_id = aws_vpc.spoke_b.id

  tags = {
    Name = "spoke-b-workload-rt-${var.project_name}"
  }
}

resource "aws_route_table_association" "spoke_b_workload" {
  subnet_id      = aws_subnet.spoke_b_workload.id
  route_table_id = aws_route_table.spoke_b_workload.id
}

resource "aws_route" "spoke_b_workload_default" {
  route_table_id         = aws_route_table.spoke_b_workload.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.spoke_b]
}

resource "aws_route_table" "spoke_b_tgw" {
  vpc_id = aws_vpc.spoke_b.id

  tags = {
    Name = "spoke-b-tgw-rt-${var.project_name}"
  }
}

resource "aws_route_table_association" "spoke_b_tgw" {
  subnet_id      = aws_subnet.spoke_b_tgw.id
  route_table_id = aws_route_table.spoke_b_tgw.id
}
