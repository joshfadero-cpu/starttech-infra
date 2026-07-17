variable "vpc_id" {
  description = "VPC ID where the ALB runs"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID of the EKS worker nodes"
  type        = string
}

variable "node_asg_name" {
  description = "Auto scaling group name of the EKS node group, attached to the target group"
  type        = string
}

variable "node_port" {
  description = "NodePort on the workers where the backend service listens"
  type        = number
  default     = 30080
}

variable "health_check_path" {
  description = "HTTP path the target group health check probes on the backend"
  type        = string
  default     = "/health"
}

variable "bucket_regional_domain_name" {
  description = "Regional domain name of the frontend S3 bucket"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the frontend S3 bucket, used in the OAC bucket policy"
  type        = string
}

variable "bucket_id" {
  description = "ID (name) of the frontend S3 bucket"
  type        = string
}
