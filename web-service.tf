data "template_file" "user_data" {
  template = file("userdata.yaml")
}

resource "aws_instance" "vpc_a_web_hosts" {
  count                       = 3
  ami                         = data.aws_ami.amazon-linux-2.id
  subnet_id                   = aws_subnet.spoke_vpc_a_protected_subnet[count.index].id
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  instance_type               = "t3.micro"
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.spoke_vpc_a_web_service_sg.id]
  tags = {
    Name = "spoke-vpc-a/web-host-${count.index}"
  }
  user_data = data.template_file.user_data.rendered
}

resource "aws_security_group" "spoke_vpc_a_web_service_sg" {
  name        = "spoke-vpc-a/sg-webservice-host"
  description = "Allow port 80 from Inspection VPC CIDR"
  vpc_id      = aws_vpc.spoke_vpc_a.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.inspection_vpc.cidr_block]
  }

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
    Name = "spoke-vpc-a/sg-web-host"
  }
}

resource "aws_lb" "web_service_lb" {
  name               = "webservice-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.spoke_vpc_a_protected_subnet : subnet.id]

  enable_deletion_protection = false
}


resource "aws_lb_target_group" "webservice_tg" {
  name     = "webservice-nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.spoke_vpc_a.id
}

resource "aws_lb_target_group_attachment" "webservice_tg_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.webservice_tg.arn
  target_id        = aws_instance.vpc_a_web_hosts[count.index].id
  port             = 80
}

resource "aws_lb_listener" "webservice_listener" {
  load_balancer_arn = aws_lb.web_service_lb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webservice_tg.arn
  }
}

resource "aws_lb" "public_web_service_lb" {
  name               = "public-webservice-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.inspection_vpc_public_subnet : subnet.id]
  security_groups    = [aws_security_group.public_webservice_lb_sg.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "public_webservice_tg" {
  name        = "public-webservice-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.inspection_vpc.id
}

resource "aws_lb_listener" "public_webservice_listener" {
  load_balancer_arn = aws_lb.public_web_service_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_webservice_tg.arn
  }
}

data "aws_network_interface" "nlb_enis" {
  for_each = { for k, subnet in aws_subnet.spoke_vpc_a_protected_subnet : k => subnet.id }

  filter {
    name   = "description"
    values = ["ELB net/${aws_lb.web_service_lb.name}/*"]
  }

  filter {
    name   = "subnet-id"
    values = [each.value]
  }
}
resource "aws_lb_target_group_attachment" "public_webservice_tg_attachment" {
  for_each          = data.aws_network_interface.nlb_enis
  availability_zone = "all"
  target_group_arn  = aws_lb_target_group.public_webservice_tg.arn
  target_id         = each.value.private_ip
  port              = 80
}

resource "aws_security_group" "public_webservice_lb_sg" {
  name        = "inspection-vpc/sg-webservice-alb"
  description = "Allow port 80 from everywhere and open 80 to Spoke VPC CIDRs"
  vpc_id      = aws_vpc.inspection_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "inspection-vpc/sg-webservice-alb"
  }
}

output "web_service_instance_private_ips" {
  value = aws_instance.vpc_a_web_hosts[*].private_ip
}

output "web_service_public_lb_dns" {
  value = aws_lb.public_web_service_lb.dns_name
}
