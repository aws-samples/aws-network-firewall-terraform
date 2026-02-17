// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# ---------- Prod VPC 3 ----------
resource "aws_vpc" "prod_vpc3" {
  cidr_block = var.prod_vpc3_cidr

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3"
  }
}

# ---------- Prod VPC 3 Subnets ----------
# Cloud WAN Subnets
resource "aws_subnet" "prod_vpc3_cwan" {
  count             = 2
  vpc_id            = aws_vpc.prod_vpc3.id
  cidr_block        = var.prod_vpc3_cwan_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-cwan-subnet${count.index + 1}"
  }
}

# Endpoint Subnets
resource "aws_subnet" "prod_vpc3_endpoint" {
  count             = 2
  vpc_id            = aws_vpc.prod_vpc3.id
  cidr_block        = var.prod_vpc3_endpoint_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-endpoint-subnet${count.index + 1}"
  }
}

# Workload Subnets
resource "aws_subnet" "prod_vpc3_workload" {
  count             = 2
  vpc_id            = aws_vpc.prod_vpc3.id
  cidr_block        = var.prod_vpc3_workload_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-workload-subnet${count.index + 1}"
  }
}

# ---------- Prod VPC 3 Route Tables ----------
# Cloud WAN Route Tables
resource "aws_route_table" "prod_vpc3_cwan" {
  count  = 2
  vpc_id = aws_vpc.prod_vpc3.id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-cwan-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "prod_vpc3_cwan" {
  count          = 2
  subnet_id      = aws_subnet.prod_vpc3_cwan[count.index].id
  route_table_id = aws_route_table.prod_vpc3_cwan[count.index].id
}

# Endpoint Route Tables
resource "aws_route_table" "prod_vpc3_endpoint" {
  count  = 2
  vpc_id = aws_vpc.prod_vpc3.id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-endpoint-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "prod_vpc3_endpoint" {
  count          = 2
  subnet_id      = aws_subnet.prod_vpc3_endpoint[count.index].id
  route_table_id = aws_route_table.prod_vpc3_endpoint[count.index].id
}

# Workload Route Tables
resource "aws_route_table" "prod_vpc3_workload" {
  count  = 2
  vpc_id = aws_vpc.prod_vpc3.id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-workload-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "prod_vpc3_workload" {
  count          = 2
  subnet_id      = aws_subnet.prod_vpc3_workload[count.index].id
  route_table_id = aws_route_table.prod_vpc3_workload[count.index].id
}

# ---------- Cloud WAN Attachment ----------
resource "aws_networkmanager_vpc_attachment" "prod_vpc3" {
  core_network_id = var.core_network_id
  vpc_arn         = aws_vpc.prod_vpc3.arn
  subnet_arns     = aws_subnet.prod_vpc3_cwan[*].arn

  tags = {
    Name   = "${var.project_name}-${local.region}-prod-vpc3-attachment"
    domain = "Production"
  }
}

# Default route to Core Network
resource "aws_route" "prod_vpc3_workload_default" {
  count                  = 2
  route_table_id         = aws_route_table.prod_vpc3_workload[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = var.core_network_arn

  depends_on = [aws_networkmanager_vpc_attachment.prod_vpc3]
}

# ---------- Security Groups ----------
resource "aws_security_group" "prod_vpc3_workload" {
  name        = "${var.project_name}-${local.region}-prod-vpc3-workload-sg"
  description = "Prod VPC 3 Workload EC2 Instance Security Group"
  vpc_id      = aws_vpc.prod_vpc3.id

  ingress {
    description = "Allow inbound from 10.0.0.0/8"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-workload-sg"
  }
}

resource "aws_security_group" "prod_vpc3_endpoint" {
  name        = "${var.project_name}-${local.region}-prod-vpc3-endpoint-sg"
  description = "Prod VPC 3 Endpoint Security Group"
  vpc_id      = aws_vpc.prod_vpc3.id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-endpoint-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "prod_vpc3_workload_eic" {
  security_group_id            = aws_security_group.prod_vpc3_workload.id
  description                  = "Allow SSH from EC2 Instance Connect"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.prod_vpc3_endpoint.id
}

resource "aws_vpc_security_group_egress_rule" "prod_vpc3_endpoint_eic" {
  security_group_id            = aws_security_group.prod_vpc3_endpoint.id
  description                  = "Allow SSH to workload instances"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.prod_vpc3_workload.id
}

# ---------- EC2 Instance Connect Endpoint ----------
resource "aws_ec2_instance_connect_endpoint" "prod_vpc3" {
  subnet_id          = aws_subnet.prod_vpc3_endpoint[0].id
  security_group_ids = [aws_security_group.prod_vpc3_endpoint.id]
  preserve_client_ip = false

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-eic"
  }
}

# ---------- Workload EC2 Instances ----------
resource "aws_instance" "prod_vpc3_workload" {
  count                  = 2
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.prod_vpc3_workload[count.index].id
  vpc_security_group_ids = [aws_security_group.prod_vpc3_workload.id]

  user_data = <<-EOF
    #!/bin/bash -ex
    yum update -y
    yum install -y jq httpd htop
    systemctl enable httpd
    systemctl start httpd
    hostnamectl set-hostname prod-vpc3-workload-${count.index + 1}
    echo 'ClientAliveInterval 60' | tee --append /etc/ssh/sshd_config
    systemctl restart sshd
    INSTANCE_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    INSTANCE_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
    cat <<EOT > /var/www/html/index.html
    <html>
      <head><title>Prod VPC 3 Workload Instance ${count.index + 1}</title></head>
      <body>
        <h1>Welcome to AWS Cloud WAN Egress Inspection Architecture POC:</h1>
        <h2>This is a simple web server running in $INSTANCE_AZ in $INSTANCE_REGION. Happy Testing!</h2>
      </body>
    </html>
    EOT
  EOF

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc3-workload-instance${count.index + 1}"
  }
}
