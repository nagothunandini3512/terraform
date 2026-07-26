module "vpc" {
  source = "../../modules/vpc"

  # Customer Input Values
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  environment     = var.environment
}

module "eks" {
  source = "../../modules/eks"

  cluster_name             = var.cluster_name
  kubernetes_version       = var.kubernetes_version
  endpoint_public_access   = var.endpoint_public_access
  endpoint_private_access  = var.endpoint_private_access
  cluster_admin_permission = var.cluster_admin_permission
  upgrade_policy           = var.upgrade_policy
  service_cidr             = var.service_cidr
  enable_irsa              = var.enable_irsa
  create_kms_key           = var.create_kms_key
  environment              = var.environment
  vpc_id                   = module.vpc.vpc_id
  private_subnets          = module.vpc.private_subnet_ids
  ebs_csi_role_arn         = module.iam.ebs_csi_driver_arn
  managed_node_groups = var.managed_node_groups

  depends_on = [module.vpc]
}

module "iam" {
  source = "../../modules/iam"

  cluster_name = var.cluster_name
}

module "storage" {
  source = "../../modules/storage"
}

module "alb" {
  source = "../../modules/alb"

  env_name          = var.environment
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id
  eks_name          = var.cluster_name
}

module "argocd" {
  source      = "../../modules/argocd"
  environment = var.environment
  depends_on  = [module.eks]
}
