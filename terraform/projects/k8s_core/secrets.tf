resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

data "aws_ssm_parameter" "grafana_admin_password" {
  name = "/grafana/admin/password"
}

resource "kubernetes_secret" "grafana_admin_credentials" {
  metadata {
    name      = "grafana-admin-credentials"
    namespace = kubernetes_namespace.monitoring.id
  }

  data = {
    admin-user     = "admin"
    admin-password = data.aws_ssm_parameter.grafana_admin_password.value
  }

  type = "Opaque"
}


data "aws_secretsmanager_secret" "github_private_key" {
  name = "github-private-key"
}

data "aws_secretsmanager_secret_version" "github_private_key" {
  secret_id = data.aws_secretsmanager_secret.github_private_key.id
}

resource "kubernetes_secret" "github_repository" {
  metadata {
    name      = "k8s-demo"
    namespace = kubernetes_namespace.argocd.id

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = "git@github.com:/phclark/k8s-demo"
    sshPrivateKey = data.aws_secretsmanager_secret_version.github_private_key.secret_string
  }

  type = "Opaque"
}
