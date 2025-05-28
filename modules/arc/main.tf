terraform {
  required_providers {
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

resource "helm_release" "arc_controller" {
  name             = "arc"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart            = "gha-runner-scale-set-controller"
  namespace        = var.arc_namespace
  create_namespace = true
  version          = "0.9.3"

  set {
    name  = "authSecret.create"
    value = "true"
  }
  set {
    name  = "authSecret.github_token"
    value = var.github_pat
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_namespace" "arc_runners" {
  metadata {
    name = "${var.arc_namespace}-runners"
  }
}

resource "helm_release" "arc_runner_set" {
  name             = "arc-runner-set"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart            = "gha-runner-scale-set"
  namespace        = kubernetes_namespace.arc_runners.metadata[0].name
  create_namespace = true
  version          = "0.9.3"

  set {
    name  = "githubConfigUrl"
    value = "https://github.com/${var.github_repository}"
  }
  set {
    name  = "githubConfigSecret.github_token"
    value = var.github_pat
  }
  set {
    name  = "minRunners"
    value = var.min_runners
  }
  set {
    name  = "maxRunners"
    value = var.max_runners
  }
  set {
    name  = "runnerScaleSetName"
    value = "eks-runner-scale-set"
  }
  set {
    name  = "controllerServiceAccount.namespace"
    value = var.arc_namespace
  }
  set {
    name  = "controllerServiceAccount.name"
    value = "arc-gha-rs-controller"
  }

  depends_on = [helm_release.arc_controller]
}

resource "null_resource" "wait_for_crds" {
  provisioner "local-exec" {
    command = <<EOT
      until kubectl get crd horizontalrunnerautoscalers.actions.summerwind.dev --output=name 2>/dev/null; do
        echo "Waiting for HorizontalRunnerAutoscaler CRD..."
        sleep 8
      done
    EOT
  }
  depends_on = [helm_release.arc_controller]
}

resource "kubernetes_manifest" "horizontal_runner_autoscaler" {
  manifest = {
    apiVersion = "actions.summerwind.dev/v1alpha1"
    kind       = "HorizontalRunnerAutoscaler"
    metadata = {
      name      = "eks-runner-autoscaler"
      namespace = kubernetes_namespace.arc_runners.metadata[0].name
    }
    spec = {
      scaleTargetRef = {
        kind = "RunnerDeployment"
        name = "eks-runner-scale-set"
      }
      minReplicas = var.min_runners
      maxReplicas = var.max_runners
      metrics = [
        {
          type            = "TotalNumberOfQueuedAndInProgressWorkflowRuns"
          repositoryNames = [split("/", var.github_repository)[1]]
        }
      ]
    }
  }
  depends_on = [null_resource.wait_for_crds, helm_release.arc_runner_set]
}
