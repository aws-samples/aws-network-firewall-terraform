# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Network Load Balancer
resource "aws_lb" "network_load_balancer" {
  name               = "${var.project_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.nlb.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-nlb"
  }
}

# Target Group for NLB
resource "aws_lb_target_group" "nlb_target_group" {
  name     = "${var.project_name}-nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-nlb-tg"
  }
}

# NLB Listener
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.network_load_balancer.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }

  tags = {
    Name = "${var.project_name}-nlb-listener"
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "nlb_target_attachment" {
  target_group_arn = aws_lb_target_group.nlb_target_group.arn
  target_id        = aws_instance.private_instance.id
  port             = 80
}