variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.34"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where the cluster and worker nodes run"
  type        = list(string)
}

variable "node_instance_type" {
  description = "Instance type for the managed node group workers"
  type        = string
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}
