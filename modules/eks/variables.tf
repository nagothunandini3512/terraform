variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "endpoint_public_access" {
  description = "Whether the EKS public API server endpoint is enabled"
  type        = bool
}

variable "endpoint_private_access" {
  description = "Whether the EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_admin_permission" {
  description = "Whether to grant the Terraform caller's IAM identity cluster-admin permissions on the EKS cluster"
  type        = bool
}

variable "upgrade_policy" {
  description = "Cluster upgrade policy configuration (support_type: STANDARD or EXTENDED)"
  type = object({
    support_type = optional(string, "STANDARD")
  })
  default = {
    support_type = "STANDARD"
  }
}

variable "service_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from"
  type        = string
}

variable "enable_irsa" {
  description = "Whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Whether to create a KMS key for cluster secrets encryption"
  type        = bool
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster and nodes will be provisioned"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs used for the EKS control plane ENIs and node groups"
  type        = list(string)
}

variable "environment" {
  description = "Environment name used for tagging (e.g. dev, staging, prod)"
  type        = string
}

variable "ebs_csi_role_arn" {
  type = string
}

variable "managed_node_groups" {
  description = "Map of EKS managed node group configurations"
  type = map(object({
    name           = string
    min_size       = number
    max_size       = number
    desired_size   = number
    ami_id         = optional(string)
    instance_types = optional(list(string))
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number)
    labels         = optional(map(string), {})
    taints = optional(map(object({
      key    = string
      value  = string
      effect = string
    })), {})
    tags = optional(map(string), {})
  }))
}

