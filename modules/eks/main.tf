resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::084766854861:role/GithubActionsWorkflowRole"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_admin" {
  cluster_name  = var.cluster_name
  principal_arn = aws_eks_access_entry.github_actions.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access  = var.endpoint_public_access
  cluster_endpoint_private_access = var.endpoint_private_access

  enable_cluster_creator_admin_permissions = var.cluster_admin_permission
  cluster_upgrade_policy                   = var.upgrade_policy
  cluster_service_ipv4_cidr                = var.service_cidr

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
    aws-ebs-csi-driver = {
      pod_identity_association = [{
        role_arn        = var.ebs_csi_role_arn
        service_account = "ebs-csi-controller-sa"
      }]
    }
  }
  enable_irsa    = var.enable_irsa
  create_kms_key = var.create_kms_key

  control_plane_subnet_ids = var.private_subnets

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  #access_entries = var.access_entries
  eks_managed_node_groups = var.managed_node_groups


  tags = {
    cluster     = var.cluster_name
    Environment = var.environment
  }
}

