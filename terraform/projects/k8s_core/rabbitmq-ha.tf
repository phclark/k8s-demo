resource "helm_release" "argocd" {
  name             = "rabbitmq-ha"
  repository       = "s3://k8s-demo-dev-helm-charts"
  chart            = "rabbitmq-ha"
  version          = "1.47.1"
  namespace        = "rabbitmq"
  create_namespace = true
}
