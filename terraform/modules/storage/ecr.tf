# ------------------------------------------------------------------
# ECR repository for the backend container image
# ------------------------------------------------------------------

resource "aws_ecr_repository" "backend" {
  name         = var.ecr_repo_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
