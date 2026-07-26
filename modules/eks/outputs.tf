output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

output "cluster_auth_token" {
  description = "Authentication token for the EKS cluster"
  value       = data.aws_eks_cluster_auth.this.token
  sensitive   = true
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "EKS Clusters oidc provider arn"
}
