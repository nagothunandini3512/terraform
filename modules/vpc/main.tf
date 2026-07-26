data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


locals {
  nat_gateway_config = var.environment == "dev" ? {
    single_nat_gateway     = true
    one_nat_gateway_per_az = false
    } : {
    single_nat_gateway     = false
    one_nat_gateway_per_az = true
  }
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.19"
  name    = var.vpc_name
  cidr    = var.vpc_cidr


  azs             = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnets))
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  single_nat_gateway     = local.nat_gateway_config.single_nat_gateway
  one_nat_gateway_per_az = local.nat_gateway_config.one_nat_gateway_per_az

  tags = {
    Environment = var.environment
  }
}
