resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.31.0"

  create_namespace = true

  set {
    name  = "argo-cd.global.image.tag"
    value = "v2.2.3"
  }

  set {
    name  = "argo-cd.dex.enabled"
    value = false
  }

  set {
    name  = "argo-cd.server.extraArgs"
    value = ["--insecure"]
  }
}
