module "alb_ingress_controller" {
  source                                     = "./alb-ingress-controller"
  aws_load_balancer_controller_chart_version = "1.4.1"

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = data.aws_region.current.name
  k8s_cluster_name = data.aws_eks_cluster.target.name
  # enable_host_networking = true

  alb_controller_depends_on = []
}
