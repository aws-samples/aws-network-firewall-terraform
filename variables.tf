variable "super_cidr_block" {
  type    = string
  default = "10.0.0.0/8"
}

locals {
  spoke_vpc_a_cidr    = cidrsubnet(var.super_cidr_block, 8, 10)
  spoke_vpc_b_cidr    = cidrsubnet(var.super_cidr_block, 8, 11)
  inspection_vpc_cidr = cidrsubnet(var.super_cidr_block, 8, 255)
}
