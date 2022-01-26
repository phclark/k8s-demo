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

variable "tags" {
    description = "Tags to be applied to resources"  
    default = {}
}
