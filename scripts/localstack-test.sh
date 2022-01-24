#!/bin/bash
export AWS_REGION=us-east-1
export LOCALSTACK_API_KEY="`cat LOCALSTACK_API_KEY`"
# Start localstack, apply terraform config, and run tests

# Start LocalStack in the background
localstack stop
localstack start -d

# Wait 30 seconds for the LocalStack container to become ready before timing out
echo "Waiting for LocalStack startup..."
localstack wait -t 30
echo "Startup complete"

cd terraform
../scripts/symlink.sh
cd projects/environment/environments/dev

# Remove real AWS provider and replace with localstack provider
rm aws.tf

# Init and apply terraform config
terraform init
terraform apply --auto-approve

#sleep 30
# terraform destroy --auto-approve

# Return localstack provider to hidden 
# mv localstack.tf localstack.ignore_tf
