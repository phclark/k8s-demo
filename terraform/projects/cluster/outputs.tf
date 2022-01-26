output "cluster_name" {
    value = module.eks.cluster_id
}

output "cluster_endpoint" {
    value = module.eks.cluster_endpoint
}

output "oidc_issuer_url" {
    value = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
    value = module.eks.oidc_provider_arn
}

output "cluster_addons" {
    value = module.eks.cluster_addons
}

output "cluster_status" {
    value = module.eks.cluster_status
}

output "vpc_arn" {
    value = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
    value = module.vpc.vpc_cidr_block
}

output "vpc_id" {
    value = module.vpc.vpc_id
}

output "private_subnets" {
    value = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
    value = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
    value = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
    value = module.vpc.public_subnets_cidr_blocks
}