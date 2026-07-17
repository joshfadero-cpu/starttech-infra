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

# ------------------------------------------------------------------
# Networking: VPC, subnets, IGW, NAT, route tables
# ------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  vpc_name             = "starttech-vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_name         = var.cluster_name
}

# ------------------------------------------------------------------
# EKS: cluster and managed node group
# ------------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  private_subnet_ids = module.networking.private_subnet_ids
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
}
