#!/bin/bash

cd /home/ubuntu/LimeLight-Video
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
INSTANCE_NAME=$(aws ec2 describe-tags --region $REGION --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)


if [ "$INSTANCE_NAME" == "LimeLight-Video" ]; then
  docker compose -f docker-compose-production.worker.yml up -d
else
  docker compose -f docker-compose-production.cpu.yml up -d
fi
