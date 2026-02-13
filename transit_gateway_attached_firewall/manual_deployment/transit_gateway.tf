// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#------------------------------------------------------------------------------
# Transit Gateway
#------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "main" {
  amazon_side_asn                 = 65000
  description                     = "TGW Network Firewall Demo"
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "tgw-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Transit Gateway VPC Attachments
#------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_a" {
  subnet_ids         = [aws_subnet.spoke_a_tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.spoke_a.id

  tags = {
    Name = "spoke-a-attach-${var.project_name}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_b" {
  subnet_ids         = [aws_subnet.spoke_b_tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.spoke_b.id

  tags = {
    Name = "spoke-b-attach-${var.project_name}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress" {
  subnet_ids             = [aws_subnet.egress_tgw.id]
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  vpc_id                 = aws_vpc.egress.id
  appliance_mode_support = "enable"

  tags = {
    Name = "egress-attach-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Transit Gateway Route Tables
#------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "spoke-route-table-${var.project_name}"
  }
}

resource "aws_ec2_transit_gateway_route_table" "egress" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "egress-route-table-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Transit Gateway Route Table Associations
#------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table_association" "spoke_a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke_b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_b.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress.id
}

#------------------------------------------------------------------------------
# Transit Gateway Route Table Propagations
#------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_a_to_spoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_b_to_spoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_b.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_a_to_egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_b_to_egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_b.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress.id
}

#------------------------------------------------------------------------------
# Transit Gateway Static Routes
#------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route" "spoke_to_egress" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}
