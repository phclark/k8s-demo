resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "4.5.3"
  namespace  = kubernetes_namespace.argocd.id

  create_namespace = false

  values = [
    templatefile("${path.root}/argocd-values.yaml", {
    })
  ]

  depends_on = [
    module.alb_ingress_controller
  ]
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}

resource "kubernetes_manifest" "demo-root-app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "demo"
      namespace = kubernetes_namespace.argocd.id
    }

    spec = {
      destination = {
        server = "https://kubernetes.default.svc"
      }
      project = "default"
      source = {
        path           = "charts/root"
        repoURL        = "https://github.com/phclark/k8s-demo.git"
        targetRevision = "main"
      }
    }
  }
}
