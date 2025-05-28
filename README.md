EKS Cluster Terraform Configuration
Overview
This Terraform configuration sets up an AWS EKS cluster using the official AWS EKS Terraform module.
Prerequisites

Terraform >= 1.0
AWS CLI configured with appropriate credentials
IAM role with necessary EKS permissions
VPC and subnets properly configured

Usage

Initialize Terraform:

terraform init


Review and modify terraform.tfvars with your specific values

Plan the deployment:


terraform plan


Apply the configuration:

terraform apply

Important Notes

Ensure the IAM role ARN has the necessary permissions for EKS
Verify VPC and subnet configurations
Adjust node group parameters (instance types, sizes) as needed
The configuration enables cluster logging by default

