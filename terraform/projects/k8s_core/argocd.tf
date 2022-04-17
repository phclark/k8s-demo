resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.31.0"
  namespace  = "argocd"

  create_namespace = true

  values = [
    templatefile("${path.module}/argocd-values.yaml", {
    })
  ]
}

data "aws_secretsmanager_secret" "github_private_key" {
  name = "github-private-key"
}

resource "kubernetes_secret" "github_private_key" {
  name      = "github-private-key"
  namespace = "argocd"

  metadata {

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
