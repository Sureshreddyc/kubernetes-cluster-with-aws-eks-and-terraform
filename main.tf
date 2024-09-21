terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Variables
variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "user_name" {
  description = "IAM user for attaching policies"
  default     = "suresh"  # Default to your IAM username
}

# Data source to get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  name = "stw-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  public_subnets  = ["10.0.100.0/22", "10.0.104.0/22", "10.0.108.0/22"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
}

# Locals for VPC and subnets
locals {
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.vpc_cidr_block
  public_subnets_ids  = module.vpc.public_subnets
  private_subnets_ids = module.vpc.private_subnets
}

# EKS Cluster Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "poc-eks-cluster"
  cluster_version = "1.24"
  cluster_endpoint_public_access = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnets_ids
  control_plane_subnet_ids = local.private_subnets_ids

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    instance_types             = ["t3.medium"]
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    stw_node_wg = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
    }
  }
}

# IAM User Creation with Full Access Policy
resource "aws_iam_user" "admin_user" {
  name = var.user_name
}

resource "aws_iam_policy" "eks_full_access_policy" {
  name        = "eks-full-access-policy"
  description = "Full access policy for EKS management"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:*",
          "iam:*",
          "logs:*",
          "ec2:*",
          "cloudwatch:*",
          "autoscaling:*",
          "elasticloadbalancing:*",
          "ecr:*",
          "s3:*",
          "route53:*",
          "vpc:*",
          "cloudformation:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "eks_full_access_attachment" {
  user       = aws_iam_user.admin_user.name
  policy_arn = aws_iam_policy.eks_full_access_policy.arn
}

# Output EKS cluster name and VPC ID
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "vpc_id" {
  description = "VPC ID of the cluster"
  value       = module.vpc.vpc_id
}
