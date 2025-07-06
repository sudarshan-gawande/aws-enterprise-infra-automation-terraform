#!/bin/bash
# Check required environment variables

REQUIRED_VARS=(DOCKERHUB_USERNAME DOCKERHUB_PASSWORD AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY)

for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var}" ]]; then
    echo "Error: $var is not set"
    exit 1
  fi
done

echo "All required environment variables are set."
