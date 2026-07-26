vpc_name                 = "prod-env-vpc"
vpc_cidr                 = "10.3.0.0/16"
public_subnets           = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
private_subnets          = ["10.3.100.0/24", "10.3.101.0/24", "10.3.102.0/24", "10.3.103.0/24", "10.3.104.0/24"]
environment              = "prod"
cluster_name             = "prod-eks-cluster"
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
    min_size       = 5
    max_size       = 6
    desired_size   = 5
    instance_types = ["t3.large"]
    capacity_type  = "ON_DEMAND"
  }
}

