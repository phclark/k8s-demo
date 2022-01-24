module "external_dns" {
  source  = "lablabs/eks-external-dns/aws"
  version = "0.9.0"

  cluster_identity_oidc_issuer     = data.terraform_remote_state.cluster.outputs.oidc_issuer_url
  cluster_identity_oidc_issuer_arn = data.terraform_remote_state.cluster.outputs.oidc_provider_arn

  values = yamlencode({
    "LogLevel" : "debug"
    "provider" : "aws"
    "registry" : "txt"
    "txtOwnerId" : "eks-cluster"
    "txtPrefix" : "external-dns"
    "policy" : "sync"
    "domainFilters" : [
      "grainfreewoodworks.com"
    ]
    "publishInternalServices" : "true"
    "triggerLoopOnEvent" : "true"
    "interval" : "5s"
  })
}
