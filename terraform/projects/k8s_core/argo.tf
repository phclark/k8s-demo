resource "helm_release" "example" {
  name  = "argocd"
  chart = "../../../../../charts/argo-cd/"

  create_namespace = true
}
