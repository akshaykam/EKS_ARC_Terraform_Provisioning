# variables.tf
variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
  default     = "YOUR_VPC_ID"  # Replace with your VPC ID
}

variable "subnet_id_1" {
  description = "First subnet ID for EKS"
  type        = string
  default     = "subnet-604e0905"
}

variable "subnet_id_2" {
  description = "Second subnet ID for EKS"
  type        = string
  default     = "subnet-985765b3"
}

variable "security_group_id" {
  description = "Security group ID for EKS"
  type        = string
  default     = "sg-096787e1b1e54da5d"
}

variable "eks_role_arn" {
  description = "IAM Role ARN for EKS cluster"
  type        = string
  default     = "arn:aws:iam::543816070942:role/AmazonEKSAutoClusterRole-Akshay"
}