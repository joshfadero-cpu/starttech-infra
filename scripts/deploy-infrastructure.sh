#!/usr/bin/env bash
# Provision the full StartTech infrastructure via Terraform.
# Usage: ./scripts/deploy-infrastructure.sh
set -euo pipefail

cd "$(dirname "$0")/../terraform"

terraform init
terraform fmt -check -recursive
terraform validate
terraform apply -auto-approve
terraform output
