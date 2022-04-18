module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.2.1"

  cluster_name                    = "${var.environment}-${var.cluster_name}"
  cluster_version                 = var.kubernetes_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["t3.medium", "t3.large", "c5.large"]
    vpc_security_group_ids = []
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      labels         = var.tags

      tags = var.tags
    }
  }

  node_security_group_additional_rules = {
    aws_lb_controller_webhook = {
      description                   = "Cluster API to AWS LB Controller webhook"
      protocol                      = "all"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  cluster_security_group_additional_rules = {
    aws_lb_controller_webhook = {
      description                = "Cluster API to AWS LB Controller webhook"
      protocol                   = "all"
      from_port                  = 9443
      to_port                    = 9443
      type                       = "ingress"
      source_node_security_group = true
    }
  }
}
