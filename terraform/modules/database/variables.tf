variable "redis_cluster_id" {
  description = "Identifier for the ElastiCache Redis cluster"
  type        = string
}

variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the Redis cluster runs"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the Redis subnet group"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID of the EKS cluster, allowed to reach Redis"
  type        = string
}
