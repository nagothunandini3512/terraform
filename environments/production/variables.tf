variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "environment" {
  type        = string
  description = "Environment name (dev/staging/prod)"
}

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
  default     = true
}

variable "upgrade_policy" {
  description = "Cluster upgrade policy configuration"
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

variable "managed_node_groups" {
  description = "Map of EKS managed node group configurations"
  type = map(object({
    name           = string
    min_size       = number
    max_size       = number
    desired_size   = number
    ami_type       = optional(string)
    instance_types = optional(list(string))
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 20)
    labels         = optional(map(string), {})
    taints = optional(map(object({
      key    = string
      value  = string
      effect = string
    })))
    tags = optional(map(string), {})
  }))
  default = {}
}

