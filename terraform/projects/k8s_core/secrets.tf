resource "kubernetes_secret" "example" {
  metadata {
    name = "grafana-admin-credentials"
  }

  data = {
    admin-user = "admin"
    admin-password = data.aws_ssm_parameter.grafana_admin_password.value

  }

  type = "Opaque"
}

data "aws_ssm_parameter" "grafana_admin_password" {
  name = "/grafana/admin/password"
}