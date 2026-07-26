vpc_name                 = "development-env-vpc"
vpc_cidr                 = "10.0.0.0/16"
public_subnets           = ["10.0.1.0/24", "10.0.22.0/24", "10.0.33.0/24"]
private_subnets          = ["10.0.120.0/24", "10.0.152.0/24", "10.0.153.0/24"]
environment              = "dev"
cluster_name             = "development-eks-cluster"
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
    min_size       = 3
    max_size       = 5
    desired_size   = 3
    instance_types = ["t3.small"]
    capacity_type  = "ON_DEMAND"
  }
}

