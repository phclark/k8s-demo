#!/bin/bash
export AWS_REGION=us-east-1
HELM_VERSION="3.8.0"
TARGET_ENV="${1:-dev}"
CLUSTER_NAME="${TARGET_ENV}-demo"
ACCOUNT_ID=767534018423
CWD=$(echo $PWD)

# Destroy eksctl created resources
eksctl delete iamserviceaccount \
    --namespace=kube-system \
    --cluster "$CLUSTER_NAME" \
    --name=aws-load-balancer-controller

aws iam delete-policy --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy"

# Destroy k8s_core resources
cd "${CWD}/terraform/projects/k8s_core/environments/$TARGET_ENV"
terraform init
terraform destroy --auto-approve

# Destroy Cluster
cd "${CWD}/terraform/projects/cluster/environments/$TARGET_ENV"
terraform init
terraform destroy --auto-approve