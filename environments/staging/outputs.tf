output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "argocd_url" {
  value = module.argocd.argocd_server_lb_hostname
}

output "argocd_admin_password" {
  value     = module.argocd.argocd_admin_password
  sensitive = true
}
