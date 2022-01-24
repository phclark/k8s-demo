variable "cluster_name" {
    type = string
    description = "Cluster Name"
    default = "demo"
}

variable "vpc_name" {
    type = string
    description = "VPC Name"
    default = "demo"
}

variable "environment" {
    type = string
    description = "Environment name (dev, qa, prod)"
}

variable "kubernetes_version" {
    type = string
    description = "Kubernetes Version"
    default = "1.21"
}

variable "instance_typ" {
    type = string
    description = "EC2 Instance type"
    default = "t4g.medium"
}