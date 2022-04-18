module "alb_ingress_controller" {
  # source  = "iplabs/alb-ingress-controller/kubernetes"
  # version = "3.4.0"
  source = "github.com/GSA/terraform-kubernetes-aws-load-balancer-controller.git?ref=v5.0.1"

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = data.aws_region.current.name
  k8s_cluster_name = data.aws_eks_cluster.target.name

  alb_controller_depends_on = []
}
