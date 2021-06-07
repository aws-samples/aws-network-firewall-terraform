// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_ec2_transit_gateway" "tgw" {
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "transit-gateway"
  }
}

resource "aws_ec2_transit_gateway_route_table" "spoke_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "spoke-route-table"
  }
}



resource "aws_ec2_transit_gateway_route_table" "inspection_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "inspection-route-table"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_vpc_a_tgw_attachment" {
  subnet_ids                                      = aws_subnet.spoke_vpc_a_tgw_subnet[*].id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.spoke_vpc_a.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "spoke-vpc-a-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke_vpc_a_tgw_attachment_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_vpc_a_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_vpc_b_tgw_attachment" {
  subnet_ids                                      = aws_subnet.spoke_vpc_b_tgw_subnet[*].id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.spoke_vpc_b.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "spoke-vpc-b-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke_vpc_b_tgw_attachment_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_vpc_b_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_vpc_tgw_attachment" {
  subnet_ids                                      = aws_subnet.inspection_vpc_tgw_subnet[*].id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.inspection_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support                          = "enable"
  tags = {
    Name = "inspection-vpc-attachment"
  }
}

resource "aws_ec2_transit_gateway_route" "spoke_route_table_default_route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
  destination_cidr_block         = "0.0.0.0/0"

}

resource "aws_ec2_transit_gateway_route_table_association" "inspection_vpc_tgw_attachment_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_route_table_propagate_spoke_vpc_a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_vpc_a_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_route_table_propagate_spoke_vpc_b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_vpc_b_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_route_table_propagate_inspection_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
}