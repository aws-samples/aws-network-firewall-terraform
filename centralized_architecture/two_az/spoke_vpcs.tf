// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#------------------------------------------------------------------------------
# Spoke A VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "spoke_a" {
  cidr_block           = var.spoke_a_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "spoke-a-${var.project_name}"
  }
}

resource "aws_subnet" "spoke_a_workload" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.spoke_a.id
  cidr_block              = cidrsubnet(var.spoke_a_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "spoke-a-workload-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_subnet" "spoke_a_tgw" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.spoke_a.id
  cidr_block              = cidrsubnet(var.spoke_a_cidr, 12, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "spoke-a-tgw-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_route_table" "spoke_a_workload" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.spoke_a.id

  tags = {
    Name = "spoke-a-workload-rt-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_route" "spoke_a_workload_default" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.spoke_a_workload[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.spoke_a]
}

resource "aws_route_table_association" "spoke_a_workload" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.spoke_a_workload[count.index].id
  route_table_id = aws_route_table.spoke_a_workload[count.index].id
}

resource "aws_route_table" "spoke_a_tgw" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.spoke_a.id

  tags = {
    Name = "spoke-a-tgw-rt-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_route_table_association" "spoke_a_tgw" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.spoke_a_tgw[count.index].id
  route_table_id = aws_route_table.spoke_a_tgw[count.index].id
}

#------------------------------------------------------------------------------
# Spoke B VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "spoke_b" {
  cidr_block           = var.spoke_b_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "spoke-b-${var.project_name}"
  }
}

resource "aws_subnet" "spoke_b_workload" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.spoke_b.id
  cidr_block              = cidrsubnet(var.spoke_b_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "spoke-b-workload-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_subnet" "spoke_b_tgw" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.spoke_b.id
  cidr_block              = cidrsubnet(var.spoke_b_cidr, 12, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "spoke-b-tgw-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_route_table" "spoke_b_workload" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.spoke_b.id

  tags = {
    Name = "spoke-b-workload-rt-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_route" "spoke_b_workload_default" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.spoke_b_workload[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.spoke_b]
}

resource "aws_route_table_association" "spoke_b_workload" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.spoke_b_workload[count.index].id
  route_table_id = aws_route_table.spoke_b_workload[count.index].id
}

resource "aws_route_table" "spoke_b_tgw" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.spoke_b.id

  tags = {
    Name = "spoke-b-tgw-rt-${count.index + 1}-${var.project_name}"
  }
}

resource "aws_route_table_association" "spoke_b_tgw" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.spoke_b_tgw[count.index].id
  route_table_id = aws_route_table.spoke_b_tgw[count.index].id
}
