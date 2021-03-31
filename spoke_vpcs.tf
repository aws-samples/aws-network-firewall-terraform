// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_vpc" "spoke_vpc_a" {
  cidr_block           = local.spoke_vpc_a_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "spoke-vpc-a"
  }
}

resource "aws_subnet" "spoke_vpc_a_protected_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.spoke_vpc_a.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.spoke_vpc_a_cidr, 8, 10 + count.index)

  tags = {
    Name = "spoke-vpc-a/${data.aws_availability_zones.available.names[count.index]}/protected-subnet"
  }
}

resource "aws_subnet" "spoke_vpc_a_endpoint_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.spoke_vpc_a.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.spoke_vpc_a_cidr, 8, 20 + count.index)

  tags = {
    Name = "spoke-vpc-a/${data.aws_availability_zones.available.names[count.index]}/endpoint-subnet"
  }
}

resource "aws_subnet" "spoke_vpc_a_tgw_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.spoke_vpc_a.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.spoke_vpc_a_cidr, 8, 30 + count.index)

  tags = {
    Name = "spoke-vpc-a/${data.aws_availability_zones.available.names[count.index]}/tgw-subnet"
  }
}


resource "aws_route_table" "spoke_vpc_a_route_table" {
  vpc_id = aws_vpc.spoke_vpc_a.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  tags = {
    Name = "spoke-vpc-a/route-table"
  }
}

resource "aws_route_table_association" "spoke_vpc_a_route_table_association" {
  count          = length(aws_subnet.spoke_vpc_a_protected_subnet[*])
  subnet_id      = aws_subnet.spoke_vpc_a_protected_subnet[count.index].id
  route_table_id = aws_route_table.spoke_vpc_a_route_table.id
}

resource "aws_vpc" "spoke_vpc_b" {
  cidr_block           = local.spoke_vpc_b_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "spoke-vpc-b"
  }
}

resource "aws_subnet" "spoke_vpc_b_protected_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.spoke_vpc_b.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.spoke_vpc_b_cidr, 8, 10 + count.index)
  tags = {
    Name = "spoke-vpc-b/${data.aws_availability_zones.available.names[count.index]}/protected-subnet"
  }
}

resource "aws_subnet" "spoke_vpc_b_endpoint_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.spoke_vpc_b.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.spoke_vpc_b_cidr, 8, 20 + count.index)

  tags = {
    Name = "spoke-vpc-b/${data.aws_availability_zones.available.names[count.index]}/endpoint-subnet"
  }
}

resource "aws_subnet" "spoke_vpc_b_tgw_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.spoke_vpc_b.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.spoke_vpc_b_cidr, 8, 30 + count.index)
  tags = {
    Name = "spoke-vpc-b/${data.aws_availability_zones.available.names[count.index]}/tgw-subnet"
  }
}

resource "aws_route_table" "spoke_vpc_b_route_table" {
  vpc_id = aws_vpc.spoke_vpc_b.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  tags = {
    Name = "spoke-vpc-b/route-table"
  }
}

resource "aws_route_table_association" "spoke_vpc_b_route_table_association" {
  count          = length(aws_subnet.spoke_vpc_b_protected_subnet[*])
  subnet_id      = aws_subnet.spoke_vpc_b_protected_subnet[count.index].id
  route_table_id = aws_route_table.spoke_vpc_b_route_table.id
}