output "arc_namespace" {
  description = "Namespace where ARC is deployed"
  value       = var.arc_namespace
}

output "runner_namespace" {
  description = "Namespace where runners are deployed"
  value       = "${var.arc_namespace}-runners"
}
