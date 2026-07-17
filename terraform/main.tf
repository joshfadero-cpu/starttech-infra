# StartTech Infrastructure - Root Configuration

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state shared between local runs and the CI/CD pipeline.
  # The bucket is the one manually created resource (bootstrap exception).
  backend "s3" {
    bucket  = "starttech-tfstate-joshfadero"
    key     = "starttech-infra/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "starttech"
      ManagedBy = "terraform"
    }
  }
}
