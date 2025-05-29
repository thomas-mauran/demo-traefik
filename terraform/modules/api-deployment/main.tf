variable "region" {
  type = string
}

resource "kubernetes_namespace" "api-namespace" {
  metadata {
    name = "api"
  }
}

resource "helm_release" "api" {
  name       = "api"
  chart      = "${path.module}/helm"
  namespace = kubernetes_namespace.api-namespace.metadata[0].name
}
