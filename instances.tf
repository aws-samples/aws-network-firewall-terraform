// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

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

resource "aws_security_group" "spoke_vpc_a_host_sg" {
  name        = "spoke-vpc-a/sg-host"
  description = "Allow all traffic from VPCs inbound and all outbound"
  vpc_id      = aws_vpc.spoke_vpc_a.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.spoke_vpc_a.cidr_block, aws_vpc.spoke_vpc_b.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "spoke-vpc-a/sg-host"
  }
}

resource "aws_security_group" "spoke_vpc_b_host_sg" {
  name        = "spoke-vpc-b/sg-host"
  description = "Allow all traffic from VPCs inbound and all outbound"
  vpc_id      = aws_vpc.spoke_vpc_b.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.spoke_vpc_a.cidr_block, aws_vpc.spoke_vpc_b.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "spoke-vpc-b/sg-host"
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
  service_name      = "com.amazonaws.eu-west-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_a_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_a_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_a_ssm_messages_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_a.id
  service_name      = "com.amazonaws.eu-west-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_a_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_a_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_a_ec2_messages_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_a.id
  service_name      = "com.amazonaws.eu-west-1.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_a_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_a_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_b_ssm_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_b.id
  service_name      = "com.amazonaws.eu-west-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_b_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_b_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_b_ssm_messages_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_b.id
  service_name      = "com.amazonaws.eu-west-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_b_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_b_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "spoke_vpc_b_ec2_messages_endpoint" {
  vpc_id            = aws_vpc.spoke_vpc_b.id
  service_name      = "com.amazonaws.eu-west-1.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.spoke_vpc_b_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.spoke_vpc_b_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_iam_role" "instance_role" {
  name               = "session-manager-instance-profile-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "session-manager-instance-profile"
  role = aws_iam_role.instance_role.name
}


resource "aws_iam_role_policy_attachment" "instance_role_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "spoke_vpc_a_host" {
  ami                    = data.aws_ami.amazon-linux-2.id
  subnet_id              = aws_subnet.spoke_vpc_a_protected_subnet[0].id
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.spoke_vpc_a_host_sg.id]
  tags = {
    Name = "spoke-vpc-a/host"
  }
  user_data = file("install-nginx.sh")
}

resource "aws_instance" "spoke_vpc_b_host" {
  ami                    = data.aws_ami.amazon-linux-2.id
  subnet_id              = aws_subnet.spoke_vpc_b_protected_subnet[0].id
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.spoke_vpc_b_host_sg.id]
  tags = {
    Name = "spoke-vpc-b/host"
  }
  user_data = file("install-nginx.sh")
}

output "spoke_vpc_a_host_ip" {
  value = aws_instance.spoke_vpc_a_host.private_ip
}

output "spoke_vpc_b_host_ip" {
  value = aws_instance.spoke_vpc_b_host.private_ip
}