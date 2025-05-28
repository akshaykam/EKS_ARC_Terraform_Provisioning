terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source = "../../modules/eks"

  vpc_id            = var.vpc_id
  subnet_id_1       = var.subnet_id_1
  subnet_id_2       = var.subnet_id_2
  security_group_id = var.security_group_id
  eks_role_arn      = var.eks_role_arn
#  cluster_endpoint_public_access       = true
#  cluster_endpoint_private_access      = true
#  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]  # or restrict to your IP
}

module "arc" {
  source = "../../modules/arc"

  github_repository = var.github_repository
  github_pat        = var.github_pat
  arc_namespace     = var.arc_namespace
  min_runners       = var.min_runners
  max_runners       = var.max_runners

  depends_on = [module.eks]
}
