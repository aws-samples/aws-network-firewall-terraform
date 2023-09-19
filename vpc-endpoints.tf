resource "aws_security_group" "spoke_vpc_a_endpoint_sg" {
  name        = "spoke-vpc-a/sg-ssm-ec2-endpoints"
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = aws_vpc.spoke_vpc_a.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.spoke_vpc_a.cidr_block]
  }
  tags = {
    Name = "spoke-vpc-a/sg-ssm-ec2-endpoints"
  }
}


resource "aws_security_group" "spoke_vpc_b_endpoint_sg" {
  name        = "spoke-vpc-b/sg-ssm-ec2-endpoints"
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = aws_vpc.spoke_vpc_b.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.spoke_vpc_b.cidr_block]
  }
  tags = {
    Name = "spoke-vpc-b/sg-ssm-ec2-endpoints"
  }
}

resource "aws_vpc_endpoint" "spoke_vpc_a_ssm_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_a.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_a_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_a_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_a_ssm_messages_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_a.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_a_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_a_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_a_ec2_messages_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_a.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_a_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_a_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_b_ssm_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_b.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_b_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_b_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_b_ssm_messages_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_b.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_b_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_b_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_b_ec2_messages_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_b.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_b_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_b_endpoint_sg.id,
  ]
  private_dns_enabled = true
}
