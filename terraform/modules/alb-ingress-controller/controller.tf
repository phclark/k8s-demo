resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = local.alb_controller_helm_repo
  chart      = local.alb_controller_chart_name
  version    = local.alb_controller_chart_version
  namespace  = var.k8s_namespace
  atomic     = true
  timeout    = 900

  dynamic "set" {

    for_each = {
      "clusterName"           = var.k8s_cluster_name
      "serviceAccount.create" = (var.k8s_cluster_type != "eks")
      "serviceAccount.name"   = (var.k8s_cluster_type == "eks") ? kubernetes_service_account.this.metadata[0].name : null
      "region"                = local.aws_region_name
      "vpcId"                 = local.aws_vpc_id
      "hostNetwork"           = var.enable_host_networking
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.chart_env_overrides
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [var.alb_controller_depends_on]
}
