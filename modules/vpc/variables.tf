variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR blocks provided by the user"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks provided by the user"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/staging/prod)"
}
