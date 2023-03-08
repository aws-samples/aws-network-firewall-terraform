data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "amzn2-ami-hvm*"
}

data "aws_region" "current" {}
