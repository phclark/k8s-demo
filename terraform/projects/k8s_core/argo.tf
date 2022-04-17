resource "helm_release" "argocd" {
  name  = "argocd"
  chart = "../../../../../charts/argo-cd"

  create_namespace = true
}
