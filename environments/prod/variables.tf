# environments/prod/variables.tf

# Existing Variables
variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "subnet_id_1" {
  description = "First subnet ID for EKS"
  type        = string
}

variable "subnet_id_2" {
  description = "Second subnet ID for EKS"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for EKS"
  type        = string
}

variable "eks_role_arn" {
  description = "IAM Role ARN for EKS cluster"
  type        = string
}

# New ARC variables
variable "github_repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "arc_namespace" {
  description = "Kubernetes namespace for ARC controller"
  type        = string
  default     = "arc-systems"
}

variable "min_runners" {
  description = "Minimum number of runners"
  type        = number
  default     = 0
}

variable "max_runners" {
  description = "Maximum number of runners"
  type        = number
  default     = 5
}
