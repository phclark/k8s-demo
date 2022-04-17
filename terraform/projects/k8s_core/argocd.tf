resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.31.0"
  namespace  = kubernetes_namespace.argocd.id

  create_namespace = false

  values = [
    templatefile("${path.root}/argocd-values.yaml", {
    })
  ]
}

data "aws_secretsmanager_secret" "github_private_key" {
  name = "github-private-key"
}

resource "kubernetes_secret" "github_private_key" {
  name      = "github-private-key"
  namespace = kubernetes_namespace.argocd.id

  metadata {
    name      = "github-private-key"
    namespace = kubernetes_namespace.argocd.id
  }

  labels = {
    "argocd.argoproj.io/secret-type" = "repository"
  }

  data = {
    type          = "git"
    url           = "git@github.com:hclark/k8s-demo"
    sshPrivateKey = data.aws_secretsmanager_secret.github_private_key.value
  }
}
