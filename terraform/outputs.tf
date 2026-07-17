output "vpc_id" {
  description = "ID of the StartTech VPC"
  value       = module.networking.vpc_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "ecr_repository_url" {
  description = "URL of the backend ECR repository"
  value       = module.storage.ecr_repository_url
}

output "s3_bucket_name" {
  description = "Name of the frontend bucket"
  value       = module.storage.bucket_name
}

output "cloudfront_domain_name" {
  description = "Public HTTPS domain serving the app"
  value       = module.cdn.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "Distribution ID for cache invalidations"
  value       = module.cdn.cloudfront_distribution_id
}

output "alb_dns_name" {
  description = "DNS name of the backend ALB"
  value       = module.cdn.alb_dns_name
}

output "redis_endpoint" {
  description = "Redis primary endpoint address"
  value       = module.database.redis_endpoint
}
