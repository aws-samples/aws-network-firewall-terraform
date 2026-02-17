// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# ---------- Core Network ----------
module "core_network" {
  source = "./modules/core_network"

  project_name   = var.project_name
  edge_locations = var.edge_locations
}

# ---------- Region 1 (us-east-1) ----------
module "region1" {
  source = "./modules/region1"

  providers = {
    aws = aws.region1
  }

  project_name     = var.project_name
  core_network_id  = module.core_network.core_network_id
  core_network_arn = module.core_network.core_network_arn
  instance_type    = var.instance_type
  allowed_domains  = var.allowed_domains

  depends_on = [module.core_network]
}

# ---------- Region 2 (us-east-2) ----------
module "region2" {
  source = "./modules/region2"

  providers = {
    aws = aws.region2
  }

  project_name     = var.project_name
  core_network_id  = module.core_network.core_network_id
  core_network_arn = module.core_network.core_network_arn
  instance_type    = var.instance_type
  allowed_domains  = var.allowed_domains

  depends_on = [module.core_network]
}

# ---------- Region 3 (us-west-2) ----------
module "region3" {
  source = "./modules/region3"

  providers = {
    aws = aws.region3
  }

  project_name     = var.project_name
  core_network_id  = module.core_network.core_network_id
  core_network_arn = module.core_network.core_network_arn
  instance_type    = var.instance_type
  allowed_domains  = var.allowed_domains

  depends_on = [module.core_network]
}
