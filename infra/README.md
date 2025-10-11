Infrastructure (Phase 4 - Terraform, eu-north-1)

What this provides
- Remote state bootstrap: S3 bucket + DynamoDB lock table (unique per AWS account)
- Core infra: VPC (public/private subnets), ALB, ECS cluster, RDS (Postgres), ElastiCache (Redis), optional MSK (Kafka)
- Region: eu-north-1

Security note
- Do NOT commit AWS keys. Export them as environment variables for Terraform only during use:
  - export AWS_ACCESS_KEY_ID=...; export AWS_SECRET_ACCESS_KEY=...; export AWS_DEFAULT_REGION=eu-north-1

Bootstrap remote state (run once per account)
- cd infra/bootstrap
- terraform init
- terraform apply -auto-approve
- Outputs:
  - bucket_name
  - dynamodb_table_name

Initialize backend for this repo (no hardcoded secrets)
- cd ..
- ./init-backend.sh dev    # or staging/prod
  - This passes backend config values at init time (bucket/table) and selects workspace

Provision infra (single command)
- terraform -chdir=infra apply -var env=dev -auto-approve

Toggles and costs
- MSK can be expensive. It is disabled by default. To enable: -var enable_msk=true
- RDS/Redis are sized small by default. Adjust in variables if needed.

Outputs
- alb_dns_name: use this DNS to test services (ACM/custom domain skipped).

This directory will contain Terraform modules and stacks in Phase 4
(VPC, RDS, ElastiCache, MSK, ECS, ALB) targeting eu-north-1, with S3+DynamoDB backend.


