# modules/eks/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "eks-cluster-AK"
  cluster_version = "1.32"

  # VPC Configuration
  vpc_id                   = var.vpc_id
  subnet_ids               = [var.subnet_id_1, var.subnet_id_2]
  control_plane_subnet_ids = [var.subnet_id_1, var.subnet_id_2]

  # Security Group Configuration
  cluster_security_group_additional_rules = {
    ingress_all = {
      description = "Allow all ingress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # EKS Cluster IAM Role
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  iam_role_arn             = var.eks_role_arn

  # Node Group Configuration
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      # Attach the provided security group
      security_group_ids = [var.security_group_id]
    }
  }

  # Enable cluster access for management
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}