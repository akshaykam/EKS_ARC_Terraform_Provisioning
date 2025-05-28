variable "arc_namespace" {
  description = "Kubernetes namespace for ARC controller"
  type        = string
  default     = "arc"
}

variable "github_repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
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
