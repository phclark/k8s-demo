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

resource "kubernetes_manifest" "dev_project" {
  manifest = yamldecode(templatefile("${path.root}/project.yaml", {
    environment         = "dev"
    kubernetes_endpoint = data.aws_eks_cluster.target.endpoint
  }))
}

resource "kubernetes_manifest" "root-app" {
  manifest = yamldecode(templatefile("${path.root}/platform.yaml", {
    environment = "dev"
  }))

  depends_on = [
    kubernetes_manifest.dev_project
  ]
}

resource "kubernetes_manifest" "dev_cluster_secret" {
  manifest = yamldecode(templatefile("${path.root}/cluster_secret.yaml", {
    environment         = "dev"
    kubernetes_endpoint = data.aws_eks_cluster.target.endpoint
    token               = data.aws_eks_cluster_auth.aws_iam_authenticator.token
    cert                = base64decode(data.aws_eks_cluster.target.certificate_authority.0.data)
  }))
}
