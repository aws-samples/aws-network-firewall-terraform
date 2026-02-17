// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# ---------- Prod VPC 4 (with local firewall) ----------
resource "aws_vpc" "prod_vpc4" {
  cidr_block = var.prod_vpc4_cidr

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4"
  }
}

# ---------- Internet Gateway ----------
resource "aws_internet_gateway" "prod_vpc4" {
  vpc_id = aws_vpc.prod_vpc4.id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-igw"
  }
}

# ---------- Prod VPC 4 Subnets ----------
# Firewall + EC2 Instance Connect Endpoint Subnets
resource "aws_subnet" "prod_vpc4_firewall" {
  count             = 2
  vpc_id            = aws_vpc.prod_vpc4.id
  cidr_block        = var.prod_vpc4_firewall_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-fwe-subnet${count.index + 1}"
  }
}

# Workload Subnets
resource "aws_subnet" "prod_vpc4_workload" {
  count             = 2
  vpc_id            = aws_vpc.prod_vpc4.id
  cidr_block        = var.prod_vpc4_workload_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-workload-subnet${count.index + 1}"
  }
}

# Public Subnets
resource "aws_subnet" "prod_vpc4_public" {
  count                   = 2
  vpc_id                  = aws_vpc.prod_vpc4.id
  cidr_block              = var.prod_vpc4_public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-public-subnet${count.index + 1}"
  }
}

# ---------- Prod VPC 4 Route Tables ----------
# Firewall Route Tables
resource "aws_route_table" "prod_vpc4_firewall" {
  count  = 2
  vpc_id = aws_vpc.prod_vpc4.id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-fwe-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "prod_vpc4_firewall" {
  count          = 2
  subnet_id      = aws_subnet.prod_vpc4_firewall[count.index].id
  route_table_id = aws_route_table.prod_vpc4_firewall[count.index].id
}

# Workload Route Tables
resource "aws_route_table" "prod_vpc4_workload" {
  count  = 2
  vpc_id = aws_vpc.prod_vpc4.id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-workload-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "prod_vpc4_workload" {
  count          = 2
  subnet_id      = aws_subnet.prod_vpc4_workload[count.index].id
  route_table_id = aws_route_table.prod_vpc4_workload[count.index].id
}

# Public Route Tables
resource "aws_route_table" "prod_vpc4_public" {
  count  = 2
  vpc_id = aws_vpc.prod_vpc4.id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-public-rtb${count.index + 1}"
  }
}

resource "aws_route_table_association" "prod_vpc4_public" {
  count          = 2
  subnet_id      = aws_subnet.prod_vpc4_public[count.index].id
  route_table_id = aws_route_table.prod_vpc4_public[count.index].id
}

# ---------- NAT Gateways ----------
resource "aws_eip" "prod_vpc4_natgw" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-natgw${count.index + 1}-eip"
  }
}

resource "aws_nat_gateway" "prod_vpc4" {
  count         = 2
  allocation_id = aws_eip.prod_vpc4_natgw[count.index].id
  subnet_id     = aws_subnet.prod_vpc4_public[count.index].id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-natgw${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.prod_vpc4]
}

# ---------- Routes ----------
# Workload route tables: default route to firewall endpoints
resource "aws_route" "prod_vpc4_workload_default" {
  count                  = 2
  route_table_id         = aws_route_table.prod_vpc4_workload[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.prod_vpc4_firewall_endpoint_ids[count.index]

  depends_on = [aws_networkfirewall_firewall.prod_vpc4]
}

# Firewall route tables: default route to NAT Gateway
resource "aws_route" "prod_vpc4_firewall_default" {
  count                  = 2
  route_table_id         = aws_route_table.prod_vpc4_firewall[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.prod_vpc4[count.index].id
}

# Public route tables: default route to IGW
resource "aws_route" "prod_vpc4_public_default" {
  count                  = 2
  route_table_id         = aws_route_table.prod_vpc4_public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.prod_vpc4.id
}

# Route return traffic from NAT Gateway through firewall to workload subnets
resource "aws_route" "prod_vpc4_public_to_workload" {
  count                  = 2
  route_table_id         = aws_route_table.prod_vpc4_public[count.index].id
  destination_cidr_block = var.prod_vpc4_workload_subnets[count.index]
  vpc_endpoint_id        = local.prod_vpc4_firewall_endpoint_ids[count.index]

  depends_on = [aws_networkfirewall_firewall.prod_vpc4]
}

# ---------- Security Groups ----------
resource "aws_security_group" "prod_vpc4_workload" {
  name        = "${var.project_name}-${local.region}-prod-vpc4-workload-sg"
  description = "Prod VPC 4 Workload EC2 Instance Security Group"
  vpc_id      = aws_vpc.prod_vpc4.id

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
    Name = "${var.project_name}-${local.region}-prod-vpc4-workload-sg"
  }
}

resource "aws_security_group" "prod_vpc4_endpoint" {
  name        = "${var.project_name}-${local.region}-prod-vpc4-endpoint-sg"
  description = "Prod VPC 4 Endpoint Security Group"
  vpc_id      = aws_vpc.prod_vpc4.id

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-endpoint-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "prod_vpc4_workload_eic" {
  security_group_id            = aws_security_group.prod_vpc4_workload.id
  description                  = "Allow SSH from EC2 Instance Connect"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.prod_vpc4_endpoint.id
}

resource "aws_vpc_security_group_egress_rule" "prod_vpc4_endpoint_eic" {
  security_group_id            = aws_security_group.prod_vpc4_endpoint.id
  description                  = "Allow SSH to workload instances"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.prod_vpc4_workload.id
}

# ---------- EC2 Instance Connect Endpoint ----------
resource "aws_ec2_instance_connect_endpoint" "prod_vpc4" {
  subnet_id          = aws_subnet.prod_vpc4_firewall[0].id
  security_group_ids = [aws_security_group.prod_vpc4_endpoint.id]
  preserve_client_ip = false

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-eic"
  }
}

# ---------- Workload EC2 Instances ----------
resource "aws_instance" "prod_vpc4_workload" {
  count                  = 2
  ami                    = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.prod_vpc4_workload[count.index].id
  vpc_security_group_ids = [aws_security_group.prod_vpc4_workload.id]

  user_data = <<-EOF
    #!/bin/bash -ex
    yum update -y
    yum install -y jq httpd htop
    systemctl enable httpd
    systemctl start httpd
    hostnamectl set-hostname prod-vpc4-workload-${count.index + 1}
    echo 'ClientAliveInterval 60' | tee --append /etc/ssh/sshd_config
    systemctl restart sshd
    INSTANCE_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    INSTANCE_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
    cat <<EOT > /var/www/html/index.html
    <html>
      <head><title>Prod VPC 4 Workload Instance ${count.index + 1}</title></head>
      <body>
        <h1>Welcome to AWS Cloud WAN Egress Inspection Architecture POC:</h1>
        <h2>This is a simple web server running in $INSTANCE_AZ in $INSTANCE_REGION. Happy Testing!</h2>
      </body>
    </html>
    EOT
  EOF

  tags = {
    Name = "${var.project_name}-${local.region}-prod-vpc4-workload-instance${count.index + 1}"
  }
}
