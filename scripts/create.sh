#!/bin/bash
# Script to create EKS cluster and Kubernetes resources from a local machine
# Usage:
# scripts/create.sh [environment]
# Argument environment defaults to dev

export AWS_REGION=us-east-1
HELM_VERSION="3.8.0"
TARGET_ENV="${1:-dev}"
CLUSTER_NAME="${TARGET_ENV}-demo"
ACCOUNT_ID=767534018423
CWD=$(echo $PWD)

###########################################################
# Install EKS Cluster and VPC
###########################################################
# Run symlink script
cd terraform
../scripts/symlink.sh
cd projects/cluster/environments/$TARGET_ENV

# Init and apply terraform config
terraform init
terraform apply --auto-approve

VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=$CLUSTER_NAME | jq -r '.Vpcs[0].VpcId')

# Install ALB Ingress and External DNS
cd "${CWD}/terraform/projects/k8s_core/environments/$TARGET_ENV"
terraform init
terraform apply --auto-approve

cd $CWD

# Connect kubectl to cluster
aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME


# Install Helm 
# wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
# tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
# mv linux-amd64/helm /usr/local/bin/helm

# Install Argo-CD
echo "Installing Argo-CD"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f charts/argo-cd/templates/service.yaml
kubectl apply -n argocd -f charts/argo-cd/templates/ingress.yaml
# helm repo add argo-cd https://argoproj.github.io/argo-helm
# helm dep update charts/argo-cd/
# kubectl create namespace argocd
# helm upgrade -n argocd argo-cd charts/argo-cd/

# Change default admin password
python3 -m pip install bcrypt
pw=$(aws ssm get-parameter --name /argocd/admin/password --with-decryption | jq -r '.Parameter.Value') 
bcrypt_pw=$(python3 -c 'import bcrypt; print(bcrypt.hashpw(b"'$pw'", bcrypt.gensalt(rounds=15)).decode("ascii"))')
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "'$bcrypt_pw'",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

# Create root Argo-CD App
argocd login argo.grainfreewoodworks.com --username admin --password $pw
argocd app create root --repo https://github.com/phclark/k8s-demo.git --path charts/root --dest-server https://kubernetes.default.svc --dest-namespace default