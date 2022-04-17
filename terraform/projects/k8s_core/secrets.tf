resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
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

data "aws_ssm_parameter" "grafana_admin_password" {
  name = "/grafana/admin/password"
}
