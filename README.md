# starttech-infra

Terraform configuration provisioning the StartTech platform on AWS: VPC networking, Amazon EKS, S3 static hosting with CloudFront, ECR, and ElastiCache Redis. Changes to `terraform/` on `main` deploy automatically via GitHub Actions.

Companion repository: [starttech-application](https://github.com/joshfadero-cpu/starttech-application) (application source, Kubernetes manifests, CI/CD).

## Architecture

A single CloudFront distribution serves as the unified HTTPS entry point:

- `/*` serves the React frontend from a fully private S3 bucket via Origin Access Control (origin id `S3-Frontend`). 403/404 responses rewrite to `/index.html` for SPA client-side routing.
- `/api/*` proxies to an Application Load Balancer over HTTP (origin id `ALB-Backend`) with caching disabled (all TTLs 0) and all headers, cookies, and query strings forwarded. A CloudFront viewer-request function strips the `/api` prefix before forwarding, because the backend registers routes at the root (`/health`, `/auth`, `/tasks`).

Behind the ALB, a target group forwards to EKS worker nodes on NodePort 30080 (explicit NodePort targets with a Terraform-managed external ALB, per the assessment's allowance). The ALB is created in Terraform rather than by the AWS Load Balancer Controller because CloudFront requires the ALB DNS name at apply time.

Workers run in private subnets and egress through a single NAT gateway. ElastiCache Redis (`starttech-redis`) accepts traffic only from the EKS cluster security group. MongoDB is external (Atlas M0), reached over TLS with the NAT elastic IP whitelisted in Atlas network access.

## Module layout

| Module | Contents |
| --- | --- |
| `networking` | VPC 10.0.0.0/16, 2 public + 2 private subnets across 2 AZs with `kubernetes.io/role/elb` and `internal-elb` tags, IGW, NAT, route tables |
| `eks` | Cluster `starttech-cluster` (v1.34, API_AND_CONFIG_MAP auth), managed node group `starttech-node-group` (2x t3.medium), IAM roles with the four standard managed policies |
| `storage` | Private S3 bucket (`starttech-frontend-bucket-*`) with public access block, ECR repo `starttech-backend-api` with scan-on-push |
| `cdn` | ALB + NodePort target group, dual-origin CloudFront distribution, OAC bucket policy, `/api` prefix-strip function |
| `database` | ElastiCache Redis subnet group, security group, single cache.t3.micro node |

## Prerequisites

- Terraform >= 1.5 (CI pins 1.15.7), AWS CLI v2 configured for an account with admin access, region `eu-west-1`
- A pre-created S3 state bucket (bootstrap exception, see `backend "s3"` in `terraform/main.tf`)
- kubectl and Docker for the deployment steps in the application repository

## Provisioning

```bash
./scripts/deploy-infrastructure.sh
```

Or manually: `cd terraform && terraform init && terraform apply`. Provisioning takes roughly 25 to 35 minutes (EKS cluster is the long pole). Outputs include the CloudFront domain, ALB DNS, ECR URL, and Redis endpoint.

## Bring-up checklist after a fresh apply

Resources are recreated with new identifiers, so after every full `terraform apply` from zero:

1. Update the Atlas network access entry with the new NAT elastic IP: `aws ec2 describe-addresses --filters "Name=tag:Name,Values=starttech-nat-eip" --query 'Addresses[0].PublicIp' --output text`
2. Refresh kubeconfig: `aws eks update-kubeconfig --region eu-west-1 --name starttech-cluster`
3. Recreate the two Kubernetes secrets (`backend-env`, `backend-env-file`) with the Atlas URI, Redis endpoint from `terraform output`, and JWT secret
4. Update `CLOUDFRONT_DISTRIBUTION_ID` in the application repo's `frontend-ci-cd.yml` with the new distribution id
5. Deploy backend and frontend using the application repository's scripts or pipelines
6. Verify: `./scripts/health-check.sh <cloudfront-domain>` in the application repo

## CI/CD

`.github/workflows/infrastructure-deploy.yml` runs `terraform fmt -check`, `validate`, and `apply -auto-approve` on pushes to `main` touching `terraform/`, sharing state with local runs through the S3 backend. Credentials are repository secrets for a dedicated CI IAM user; OIDC federation with short-lived tokens would be the production-grade upgrade.

## Teardown

```bash
cd terraform && terraform destroy
```

`force_destroy`/`force_delete` are set on the S3 bucket and ECR repository so non-empty resources do not block destruction. Kubernetes secrets and Atlas data survive teardown (secrets die with the cluster; Atlas is external).

## Security notes

- The frontend bucket blocks all public access; only the CloudFront distribution can read it, verified by source ARN condition
- Redis is reachable exclusively from the EKS cluster security group on 6379
- Worker nodes have no public IPs; the ALB accepts 80 from anywhere as the CloudFront origin path (restricting to the AWS-managed CloudFront prefix list is a known hardening)
- Grading is performed by the read-only IAM user `start-tech-grader` with an inline least-privilege policy

Submitted for Tinyuka 2025 Month 2 Assessment.
