variable "bucket_name" {
  description = "Name of the S3 bucket for the frontend static site"
  type        = string
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository for the backend image"
  type        = string
}
