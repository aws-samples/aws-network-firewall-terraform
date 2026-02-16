// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# IAM Role for EC2 instances
resource "aws_iam_role" "instance" {
  name = "${var.project_name}-ec2-role"
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
    Name = "${var.project_name}-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "instance_ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.instance.name
}

# Security Group for private instances
resource "aws_security_group" "private_instance" {
  name        = "${var.project_name}-private-instance-sg"
  description = "Security group for private EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from NLB"
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.nlb.id]
  }

  ingress {
    description     = "HTTPS from NLB"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.nlb.id]
  }

  ingress {
    description = "ICMP from VPC"
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-instance-sg"
  }
}

# Security Group for NLB
resource "aws_security_group" "nlb" {
  name        = "${var.project_name}-nlb-sg"
  description = "Security group for Network Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-nlb-sg"
  }
}

# Private EC2 Instances
resource "aws_instance" "private_1" {
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_instance.id]
  iam_instance_profile   = aws_iam_instance_profile.instance.name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Private Instance 1 - ${var.project_name}</h1>" > /var/www/html/index.html
    echo "<p>Ingress: IGW -> Ingress Firewall -> NLB -> Instance</p>" >> /var/www/html/index.html
    echo "<p>Egress: Instance -> Egress Firewall -> NAT Gateway -> IGW</p>" >> /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-private-instance-1"
  }

  depends_on = [
    aws_networkfirewall_firewall.ingress,
    aws_networkfirewall_firewall.egress
  ]
}

resource "aws_instance" "private_2" {
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_instance.id]
  iam_instance_profile   = aws_iam_instance_profile.instance.name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Private Instance 2 - ${var.project_name}</h1>" > /var/www/html/index.html
    echo "<p>Ingress: IGW -> Ingress Firewall -> NLB -> Instance</p>" >> /var/www/html/index.html
    echo "<p>Egress: Instance -> Egress Firewall -> NAT Gateway -> IGW</p>" >> /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-private-instance-2"
  }

  depends_on = [
    aws_networkfirewall_firewall.ingress,
    aws_networkfirewall_firewall.egress
  ]
}
