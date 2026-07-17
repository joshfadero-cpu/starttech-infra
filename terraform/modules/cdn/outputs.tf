output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.starttech.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution, used for cache invalidation"
  value       = aws_cloudfront_distribution.starttech.id
}

output "alb_dns_name" {
  description = "DNS name of the backend ALB"
  value       = aws_lb.backend.dns_name
}
