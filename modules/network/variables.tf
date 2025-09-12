locals {
  region = "us-east-2"
  vpc_cidr = "10.0.0.0/16"
  env = "dev"
  rtb_cider = "0.0.0.0/0"

  availability_zones = [
    "us-east-2a",
    "us-east-2b"
  ]

  # Dynamically create subnets based availability zones
  public_subnets = {
    for i, az in local.availability_zones :
    "public_${i + 1}" => {
      cidr  = cidrsubnet(local.vpc_cidr, 3, i) # Create a /19 subnet for each AZ, for private and isolated subnets, add onto total length of az array to prevent overlap
      az    = az
    }
  }

  private_subnets = {
    for i, az in local.availability_zones :
    "private_${i + 1}" => {
      cidr  = cidrsubnet(local.vpc_cidr, 3, i + length(local.availability_zones)) # Create a /19 subnet for each AZ, for private and isolated subnets, add onto total length of az array to prevent overlap
      az    = az
    }
  }

  create_isolated_subnets = false

  ingress_rules = {
    22 = "63.10.10.10/32"
    80 = "0.0.0.0/0"
  }
}