resource "helm_release" "test" {
  name       = "busybox"
  repository = "s3://k8s-demo-dev-helm-charts"
  chart      = "busybox"
  version    = "0.1.0"

  depends_on = [null_resource.helm_plugin]
}
