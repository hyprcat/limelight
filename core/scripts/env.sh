#!/bin/bash
# CodeDeploy step: write the .env file from two SSM parameters (comma separated KEY=value lists).

PARAMETER_NAME="test-project-env"
DB_PARAMETER_NAME="test-project-env-db"
ENV_FILE="/home/ubuntu/LimeLight-Core/.env"

for parameter in "$PARAMETER_NAME" "$DB_PARAMETER_NAME"; do
  value=$(aws ssm get-parameter --name "$parameter" --query 'Parameter.Value' --output text)
  IFS=',' read -ra VALUES <<< "$value"
  for line in "${VALUES[@]}"; do
    echo "$line" >> "$ENV_FILE"
  done
done

echo "Environment file '$ENV_FILE' has been created from SSM parameters '$PARAMETER_NAME' and '$DB_PARAMETER_NAME'."
