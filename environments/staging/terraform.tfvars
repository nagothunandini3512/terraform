vpc_name                 = "staging-env-vpc"
vpc_cidr                 = "10.1.0.0/16"
public_subnets           = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnets          = ["10.1.100.0/24", "10.1.101.0/24", "10.1.102.0/24"]
environment              = "staging"
cluster_name             = "staging-eks-cluster"
kubernetes_version       = "1.35"
endpoint_public_access   = true
endpoint_private_access  = true
cluster_admin_permission = true
upgrade_policy = {
  support_type = "STANDARD"
}
service_cidr   = "172.20.0.0/16"
enable_irsa    = true
create_kms_key = true
managed_node_groups = {
  general = {
    name           = "general-ng"
    min_size       = 2
    max_size       = 5
    desired_size   = 2
    instance_types = ["t3.small"]
    capacity_type  = "ON_DEMAND"
  }
}

