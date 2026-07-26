output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

# Optional: Convenience kosam AZs list kuda expose cheyochu
output "azs" {
  description = "List of Availability Zones used for subnets"
  value       = module.vpc.azs
}
