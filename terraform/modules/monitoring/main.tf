
locals {
  monitoring = "monitoring"
  grafana_alloy_chart_version = "1.1.1"
  hosted_prometheus_token_secret_name = "hosted-prometheus-token"
  hosted_prometheus_token_secret_key_name = "token"
  hosted_prometheus_token_env_var = ""
}

# Kubernetes Namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.monitoring
  }
}

# Secret for Prometheus Token
resource "kubernetes_secret" "hosted_prometheus_token" {
  metadata {
    name      = local.hosted_prometheus_token_secret_name
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "${local.hosted_prometheus_token_secret_key_name}" = var.hosted_prometheus_token
  }

  type = "Opaque"
}

# Grafana Alloy Helm Release
resource "helm_release" "grafana_alloy" {
  name       = "grafana-alloy"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = local.grafana_alloy_chart_version

  values = [
    templatefile(
      "${path.module}/helm/alloy.yaml",
      {
        hosted_prometheus_metrics_url = var.hosted_prometheus_metrics_url
        hosted_prometheus_username    = var.hosted_prometheus_username
        hosted_prometheus_token = var.hosted_prometheus_token
      }
    )
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_secret.hosted_prometheus_token
  ]
}
