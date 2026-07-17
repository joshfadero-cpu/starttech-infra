output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.starttech.name
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = aws_eks_cluster.starttech.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.starttech.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "ARN of the worker node IAM role"
  value       = aws_iam_role.node.arn
}

output "node_asg_name" {
  description = "Name of the auto scaling group created by the managed node group"
  value       = aws_eks_node_group.starttech.resources[0].autoscaling_groups[0].name
}
