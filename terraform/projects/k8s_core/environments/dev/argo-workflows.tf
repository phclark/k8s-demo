resource "kubernetes_namespace" "argo-workflows" {
  metadata {
    name = "argo-workflows"
  }
}

resource "helm_release" "argo-workflows" {
  name       = "argo-workflows"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  version    = "0.13.1"
  namespace  = kubernetes_namespace.argo-workflows.id

  create_namespace = false

  values = [
    templatefile("${path.root}/argo-workflows-values.yaml", {
    })
  ]

  depends_on = [
    module.alb_ingress_controller
  ]
}
