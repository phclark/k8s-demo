resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  count      = 0
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "4.5.3"
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

data "aws_secretsmanager_secret_version" "github_private_key" {
  secret_id = data.aws_secretsmanager_secret.github_private_key.id
}

resource "kubernetes_secret" "github_private_key" {
  metadata {
    name      = "github-private-key"
    namespace = kubernetes_namespace.argocd.id

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = "git@github.com:hclark/k8s-demo"
    sshPrivateKey = data.aws_secretsmanager_secret_version.github_private_key.secret_string
  }
}
