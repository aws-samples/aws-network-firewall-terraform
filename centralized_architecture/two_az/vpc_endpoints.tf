// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#------------------------------------------------------------------------------
# Spoke A VPC Endpoints for SSM
#------------------------------------------------------------------------------
resource "aws_security_group" "spoke_a_endpoints" {
  name        = "spoke-a-endpoints-sg-${var.project_name}"
  description = "Allow instances to access SSM Systems Manager"
  vpc_id      = aws_vpc.spoke_a.id

  ingress {
    description = "Allow HTTPS traffic from Spoke A VPC for SSM access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.spoke_a_cidr]
  }

  tags = {
    Name = "spoke-a-endpoints-sg-${var.project_name}"
  }
}

resource "aws_vpc_endpoint" "spoke_a_ssm" {
  vpc_id              = aws_vpc.spoke_a.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.spoke_a_workload[*].id
  security_group_ids  = [aws_security_group.spoke_a_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "spoke-a-ssm-endpoint-${var.project_name}"
  }
}

resource "aws_vpc_endpoint" "spoke_a_ec2messages" {
  vpc_id              = aws_vpc.spoke_a.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.spoke_a_workload[*].id
  security_group_ids  = [aws_security_group.spoke_a_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "spoke-a-ec2messages-endpoint-${var.project_name}"
  }
}

resource "aws_vpc_endpoint" "spoke_a_ssmmessages" {
  vpc_id              = aws_vpc.spoke_a.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.spoke_a_workload[*].id
  security_group_ids  = [aws_security_group.spoke_a_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "spoke-a-ssmmessages-endpoint-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# Spoke B VPC Endpoints for SSM
#------------------------------------------------------------------------------
resource "aws_security_group" "spoke_b_endpoints" {
  name        = "spoke-b-endpoints-sg-${var.project_name}"
  description = "Allow instances to access SSM Systems Manager"
  vpc_id      = aws_vpc.spoke_b.id

  ingress {
    description = "Allow HTTPS traffic from Spoke B VPC for SSM access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.spoke_b_cidr]
  }

  tags = {
    Name = "spoke-b-endpoints-sg-${var.project_name}"
  }
}

resource "aws_vpc_endpoint" "spoke_b_ssm" {
  vpc_id              = aws_vpc.spoke_b.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.spoke_b_workload[*].id
  security_group_ids  = [aws_security_group.spoke_b_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "spoke-b-ssm-endpoint-${var.project_name}"
  }
}

resource "aws_vpc_endpoint" "spoke_b_ec2messages" {
  vpc_id              = aws_vpc.spoke_b.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.spoke_b_workload[*].id
  security_group_ids  = [aws_security_group.spoke_b_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "spoke-b-ec2messages-endpoint-${var.project_name}"
  }
}

resource "aws_vpc_endpoint" "spoke_b_ssmmessages" {
  vpc_id              = aws_vpc.spoke_b.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.spoke_b_workload[*].id
  security_group_ids  = [aws_security_group.spoke_b_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "spoke-b-ssmmessages-endpoint-${var.project_name}"
  }
}
