locals {
  alb_controller_helm_repo     = "https://aws.github.io/eks-charts"
  alb_controller_chart_name    = "aws-load-balancer-controller"
  alb_controller_chart_version = var.aws_load_balancer_controller_chart_version
  aws_alb_ingress_class        = "alb"
  aws_vpc_id                   = data.aws_vpc.selected.id
  aws_region_name              = data.aws_region.current.name
  aws_iam_path_prefix          = var.aws_iam_path_prefix == "" ? null : var.aws_iam_path_prefix
}

data "aws_vpc" "selected" {
  id = var.k8s_cluster_type == "eks" ? data.aws_eks_cluster.selected[0].vpc_config[0].vpc_id : var.aws_vpc_id
}

data "aws_region" "current" {
  name = var.aws_region_name
}

data "aws_caller_identity" "current" {}

# The EKS cluster (if any) that represents the installation target.
data "aws_eks_cluster" "selected" {
  count      = var.k8s_cluster_type == "eks" ? 1 : 0
  name       = var.k8s_cluster_name
  depends_on = [var.alb_controller_depends_on]
}

# Authentication data for that cluster
data "aws_eks_cluster_auth" "selected" {
  count      = var.k8s_cluster_type == "eks" ? 1 : 0
  name       = var.k8s_cluster_name
  depends_on = [var.alb_controller_depends_on]
}

resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.k8s_namespace
    annotations = {
      # This annotation is only used when running on EKS which can
      # use IAM roles for service accounts.
      "eks.amazonaws.com/role-arn"               = aws_iam_role.this.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  depends_on = [var.alb_controller_depends_on]
}

resource "kubernetes_cluster_role" "this" {
  metadata {
    name = "aws-load-balancer-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  depends_on = [var.alb_controller_depends_on]
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = "aws-load-balancer-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata[0].name
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
}

resource "helm_release" "alb_controller" {

  name       = "aws-load-balancer-controller"
  repository = local.alb_controller_helm_repo
  chart      = local.alb_controller_chart_name
  version    = local.alb_controller_chart_version
  namespace  = var.k8s_namespace
  atomic     = true
  timeout    = 900

  dynamic "set" {

    for_each = {
      "clusterName"           = var.k8s_cluster_name
      "serviceAccount.create" = (var.k8s_cluster_type != "eks")
      "serviceAccount.name"   = (var.k8s_cluster_type == "eks") ? kubernetes_service_account.this.metadata[0].name : null
      "region"                = local.aws_region_name
      "vpcId"                 = local.aws_vpc_id
      "hostNetwork"           = var.enable_host_networking
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.chart_env_overrides
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [var.alb_controller_depends_on]
}

# Generate a kubeconfig file for the EKS cluster to use in provisioners
locals {
  kubeconfig = <<-EOF
    apiVersion: v1
    kind: Config
    current-context: terraform
    clusters:
    - name: ${data.aws_eks_cluster.selected[0].name}
      cluster:
        certificate-authority-data: ${data.aws_eks_cluster.selected[0].certificate_authority.0.data}
        server: ${data.aws_eks_cluster.selected[0].endpoint}
    contexts:
    - name: terraform
      context:
        cluster: ${data.aws_eks_cluster.selected[0].name}
        user: terraform
    users:
    - name: terraform
      user:
        token: ${data.aws_eks_cluster_auth.selected[0].token}
  EOF
}

# Since the kubernetes_provider cannot yet handle CRDs, we need to set any
# supplied TargetGroupBinding using a null_resource.
#
# The method used below for securely specifying the kubeconfig to provisioners
# without spilling secrets into the logs comes from:
# https://medium.com/citihub/a-more-secure-way-to-call-kubectl-from-terraform-1052adf37af8
#
# The method used below for referencing external resources in a destroy
# provisioner via triggers comes from
# https://github.com/hashicorp/terraform/issues/23679#issuecomment-886020367
resource "null_resource" "supply_target_group_arns" {
  count = (length(var.target_groups) > 0) ? length(var.target_groups) : 0

  triggers = {
    kubeconfig  = base64encode(local.kubeconfig)
    cmd_create  = <<-EOF
      cat <<YAML | kubectl -n ${var.k8s_namespace} --kubeconfig <(echo $KUBECONFIG | base64 --decode) apply -f -
      apiVersion: elbv2.k8s.aws/v1beta1
      kind: TargetGroupBinding
      metadata:
        name: ${lookup(var.target_groups[count.index], "name", "")}-tgb
      spec:
        serviceRef:
          name: ${lookup(var.target_groups[count.index], "name", "")}
          port: ${lookup(var.target_groups[count.index], "backend_port", "")}
        targetGroupARN: ${lookup(var.target_groups[count.index], "target_group_arn", "")}
        targetType:  ${lookup(var.target_groups[count.index], "target_type", "instance")}
      YAML
    EOF
    cmd_destroy = "kubectl -n ${var.k8s_namespace} --kubeconfig <(echo $KUBECONFIG | base64 --decode) delete TargetGroupBinding ${lookup(var.target_groups[count.index], "name", "")}-tgb"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
    command = self.triggers.cmd_create
  }
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
    command = self.triggers.cmd_destroy
  }
  depends_on = [helm_release.alb_controller]
}
