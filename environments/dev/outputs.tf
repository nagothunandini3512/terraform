output "vpc_id" {
  value = module.vpc_dev.vpc_id
}

output "public_subnets" {
  value = module.vpc_dev.public_subnet_ids
}

output "private_subnets" {
  value = module.vpc_dev.private_subnet_ids
}
output "argocd_url" {
  value = module.argocd.argocd_server_lb_hostname
}

