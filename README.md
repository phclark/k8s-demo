# k8s-demo

![Python](https://img.shields.io/badge/python-v3.9+-blue.svg)
[![Services CI](https://github.com/phclark/k8s-demo/actions/workflows/services_ci.yml/badge.svg)](https://github.com/phclark/k8s-demo/actions/workflows/services_ci.yml)
[![Terraform CD](https://github.com/phclark/k8s-demo/actions/workflows/terraform_cd.yml/badge.svg)](https://github.com/phclark/k8s-demo/actions/workflows/terraform_cd.yml)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=phclark_k8s-demo&metric=coverage)](https://sonarcloud.io/summary/new_code?id=phclark_k8s-demo)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)


This repo is a demonstration of a simple Kubernetes cluster used to serve a basic REST microservice endpoint, hosted AWS. 

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