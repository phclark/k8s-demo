module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.11.3"

  name = "${var.environment}-${var.vpc_name}"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b","us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  aws_default_security_group = aws_default_security_group.default.id

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.environment}-${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.environment}-${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }
  tags = var.tags
}

resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id
}