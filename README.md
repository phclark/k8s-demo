# k8s-demo

Objective: Deploy a REST microservice endpoint to a Kubernetes cluster hosted in AWS. 

This repository deploys the core AWS infrastructure along with the Kubernetes resources required to host the service. 

## CI / CD Workflow

### Docker CI
Scans, tests, and builds docker images. When complete, publishes to images to ECR. Triggers on any change to /docker

### Terraform CI
Scans, tests, and packages terraform modules as zip files to S3. Triggers on any change to /terraform/modules

### Terraform CD
Pulls referenced versions of terraform modules and applies terraform project. 

## Cloud Resources
* Shared Resources
  * VPC
  * Subnets 
  * Availability Zones
  * Security groups
* EKS Cluster

## Kubernetes Resources
* ArgoCD
* Prometheus
* Grafana
* Demo Microservice

## Resource Configuration
* terraform
  * modules
    * cluster
      * VPC (including subnets, route tables, etc)
      * IAM roles
      * ASG
      * ALB
      * EKS cluster
      
  * projects
    * environment
      * environments
        * dev
        * prod