locals {
  service_account_name = "argo-workflows-actions"

}

resource "kubernetes_namespace" "argo-workflows" {
  metadata {
    name = "argo-workflows"
  }
}

resource "helm_release" "argo-workflows" {
  name       = "argo-workflows"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  version    = "0.13.1"
  namespace  = kubernetes_namespace.argo-workflows.id

  create_namespace = false

  values = [
    templatefile("${path.root}/argo-workflows-values.yaml", {
    })
  ]

  depends_on = [
    module.alb_ingress_controller
  ]
}

resource "kubernetes_service_account" "workflows" {
  automount_service_account_token = true
  metadata {
    name      = local.service_account_name
    namespace = kubernetes_namespace.argo-workflows.id
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.workflows.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
    labels = {
      "app.kubernetes.io/name"       = local.service_account_name
      "app.kubernetes.io/component"  = "argo-workflows"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "aws_iam_role" "this" {
  name                  = local.service_account_name
  description           = "Permissions required by the Kubernetes Argo Workflows"
  path                  = "/"
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.eks_oidc_assume_role.json
}

data "aws_iam_policy_document" "eks_oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.target[0].identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${kubernetes_namespace.argo-workflows.id}:${local.service_account_name}"
      ]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.target[0].identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}

resource "aws_iam_policy" "this" {
  name        = local.service_account_name
  description = "Permissions that are required by Argo Workflows"
  path        = "/"
  policy      = file("${path.root}/argo-workflows-iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}
