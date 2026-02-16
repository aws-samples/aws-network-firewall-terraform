// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Network Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.nlb.id]
  security_groups    = [aws_security_group.nlb.id]

  tags = {
    Name = "${var.project_name}-nlb"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-nlb-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = 80
  }

  tags = {
    Name = "${var.project_name}-nlb-tg"
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.private_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.private_2.id
  port             = 80
}

# Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
