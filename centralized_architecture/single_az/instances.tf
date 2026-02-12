// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#------------------------------------------------------------------------------
# IAM Role for EC2 Instances (SSM Access)
#------------------------------------------------------------------------------
resource "aws_iam_role" "spoke_a_instance" {
  name = "spoke-a-instance-role-${var.project_name}"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "spoke-a-instance-role-${var.project_name}"
  }
}

resource "aws_iam_role_policy_attachment" "spoke_a_ssm" {
  role       = aws_iam_role.spoke_a_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "spoke_a" {
  name = "spoke-a-instance-profile-${var.project_name}"
  role = aws_iam_role.spoke_a_instance.name
}

resource "aws_iam_role" "spoke_b_instance" {
  name = "spoke-b-instance-role-${var.project_name}"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "spoke-b-instance-role-${var.project_name}"
  }
}

resource "aws_iam_role_policy_attachment" "spoke_b_ssm" {
  role       = aws_iam_role.spoke_b_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "spoke_b" {
  name = "spoke-b-instance-profile-${var.project_name}"
  role = aws_iam_role.spoke_b_instance.name
}

#------------------------------------------------------------------------------
# Security Groups for EC2 Instances
#------------------------------------------------------------------------------
resource "aws_security_group" "spoke_a_workload" {
  name        = "spoke-a-workload-sg-${var.project_name}"
  description = "ICMP access from 10.0.0.0/8 and inspection VPC"
  vpc_id      = aws_vpc.spoke_a.id

  ingress {
    description = "Allow ICMP from private networks"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "Allow ICMP from inspection VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.inspection_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "spoke-a-workload-sg-${var.project_name}"
  }
}

resource "aws_security_group" "spoke_b_workload" {
  name        = "spoke-b-workload-sg-${var.project_name}"
  description = "ICMP access from 10.0.0.0/8 and inspection VPC"
  vpc_id      = aws_vpc.spoke_b.id

  ingress {
    description = "Allow ICMP from private networks"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "Allow ICMP from inspection VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.inspection_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "spoke-b-workload-sg-${var.project_name}"
  }
}

#------------------------------------------------------------------------------
# EC2 Instances
#------------------------------------------------------------------------------
resource "aws_instance" "spoke_a" {
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.spoke_a_workload.id
  vpc_security_group_ids = [aws_security_group.spoke_a_workload.id]
  iam_instance_profile   = aws_iam_instance_profile.spoke_a.name

  tags = {
    Name = "spoke-a-${var.project_name}"
  }
}

resource "aws_instance" "spoke_b" {
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.spoke_b_workload.id
  vpc_security_group_ids = [aws_security_group.spoke_b_workload.id]
  iam_instance_profile   = aws_iam_instance_profile.spoke_b.name

  tags = {
    Name = "spoke-b-${var.project_name}"
  }
}
