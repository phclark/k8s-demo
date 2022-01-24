provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.target.endpoint
    token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority.0.data)
  }
}

data "aws_region" "current" {}

data "aws_eks_cluster" "target" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.target.name
}
