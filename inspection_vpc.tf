// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_vpc" "inspection_vpc" {
  cidr_block       = local.inspection_vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "inspection-vpc"
  }
}

resource "aws_subnet" "inspection_vpc_public_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.inspection_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.inspection_vpc_cidr, 8, 10 + count.index)
  depends_on              = [aws_internet_gateway.inspection_vpc_igw]
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/public-subnet"
  }
}

resource "aws_subnet" "inspection_vpc_firewall_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.inspection_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.inspection_vpc_cidr, 8, 20 + count.index)
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/firewall-subnet"
  }
}

resource "aws_internet_gateway" "inspection_vpc_igw" {
  vpc_id = aws_vpc.inspection_vpc.id
  tags = {
    Name = "inspection-vpc/internet-gateway"
  }
}

resource "aws_eip" "inspection_vpc_nat_gw_eip" {
  count = length(data.aws_availability_zones.available.names)
}

resource "aws_nat_gateway" "inspection_vpc_nat_gw" {
  count         = length(data.aws_availability_zones.available.names)
  depends_on    = [aws_internet_gateway.inspection_vpc_igw, aws_subnet.inspection_vpc_public_subnet]
  allocation_id = aws_eip.inspection_vpc_nat_gw_eip[count.index].id
  subnet_id     = aws_subnet.inspection_vpc_public_subnet[count.index].id
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/nat-gateway"
  }
}



resource "aws_subnet" "inspection_vpc_tgw_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.inspection_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.inspection_vpc_cidr, 8, 30 + count.index)
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/tgw-subnet"
  }
}

resource "aws_route_table" "inspection_vpc_tgw_subnet_route_table" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.inspection_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    # https://github.com/hashicorp/terraform-provider-aws/issues/16759
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_anfw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.inspection_vpc_firewall_subnet[count.index].id], 0)
  }
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/tgw-subnet-route-table"
  }
}

resource "aws_route_table_association" "inspection_vpc_tgw_subnet_route_table_association" {
  count          = length(data.aws_availability_zones.available.names)
  route_table_id = aws_route_table.inspection_vpc_tgw_subnet_route_table[count.index].id
  subnet_id      = aws_subnet.inspection_vpc_tgw_subnet[count.index].id
}

resource "aws_route_table" "inspection_vpc_firewall_subnet_route_table" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.inspection_vpc.id
  route {
    cidr_block         = var.super_cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.inspection_vpc_nat_gw[count.index].id
  }
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/firewall-subnet-route-table"
  }
}

resource "aws_route_table_association" "inspection_vpc_firewall_subnet_route_table_association" {
  count          = length(data.aws_availability_zones.available.names)
  route_table_id = aws_route_table.inspection_vpc_firewall_subnet_route_table[count.index].id
  subnet_id      = aws_subnet.inspection_vpc_firewall_subnet[count.index].id
}

resource "aws_route_table" "inspection_vpc_public_subnet_route_table" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.inspection_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inspection_vpc_igw.id
  }
  route {
    cidr_block = var.super_cidr_block
    # https://github.com/hashicorp/terraform-provider-aws/issues/16759
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_anfw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.inspection_vpc_firewall_subnet[count.index].id], 0)
  }
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/public-subnet-route-table"
  }
}

resource "aws_route_table_association" "inspection_vpc_public_subnet_route_table_association" {
  count          = length(data.aws_availability_zones.available.names)
  route_table_id = aws_route_table.inspection_vpc_public_subnet_route_table[count.index].id
  subnet_id      = aws_subnet.inspection_vpc_public_subnet[count.index].id
}
