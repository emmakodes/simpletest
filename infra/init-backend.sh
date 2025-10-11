#!/usr/bin/env bash
set -euo pipefail

ENV_NAME=${1:-dev}

cd "$(dirname "$0")/bootstrap"
terraform init -input=false
terraform apply -auto-approve -input=false

BUCKET=$(terraform output -raw bucket_name)
TABLE=$(terraform output -raw dynamodb_table_name)

cd ..
terraform init -input=false \
  -backend-config="bucket=$BUCKET" \
  -backend-config="key=todo/$ENV_NAME/terraform.tfstate" \
  -backend-config="region=eu-north-1" \
  -backend-config="dynamodb_table=$TABLE"

terraform workspace list | grep -q " $ENV_NAME$" || terraform workspace new "$ENV_NAME"
terraform workspace select "$ENV_NAME"

echo "Backend initialized with bucket=$BUCKET table=$TABLE workspace=$ENV_NAME"


