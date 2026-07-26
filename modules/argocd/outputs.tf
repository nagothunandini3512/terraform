output "argocd_server_lb_hostname" {
  description = "LoadBalancer DNS name for ArgoCD server"
  value       = try(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname, null)
}

