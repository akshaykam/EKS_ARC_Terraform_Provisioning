# modules/eks/outputs.tf
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "node_group_arn" {
  description = "ARN of the EKS managed node group"
  value       = module.eks.eks_managed_node_groups["default"].node_group_arn
}

output "node_group_id" {
  description = "ID of the EKS managed node group"
  value       = module.eks.eks_managed_node_groups["default"].node_group_id
}
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster"
  value       = module.eks.cluster_certificate_authority_data
}
