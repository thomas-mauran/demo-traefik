resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "35.4.0"
  namespace  = "traefik"
  create_namespace = true

  skip_crds = false

  # optional values
  values = [
    file("${path.module}/helm/values.yaml")
  ]
}

// External services
resource "kubernetes_manifest" "external_us_service" {
  manifest = yamldecode(file("${path.module}/helm/external-us-service.yaml"))

  depends_on = [helm_release.traefik]
}

resource "kubernetes_manifest" "external_eu_service" {
  manifest = yamldecode(file("${path.module}/helm/external-eu-service.yaml"))

  depends_on = [helm_release.traefik]
}

// Server transport

resource "kubernetes_manifest" "server_transport" {
  manifest = yamldecode(file("${path.module}/helm/servertransport.yaml"))

  depends_on = [helm_release.traefik]
}

// Middlewares
resource "kubernetes_manifest" "geoip_middleware" {
  manifest = yamldecode(file("${path.module}/helm/geoip-middleware.yaml"))

  depends_on = [helm_release.traefik]
}

resource "kubernetes_manifest" "middleware_eu_header" {
  manifest = yamldecode(file("${path.module}/helm/middleware-eu-header.yaml"))

  depends_on = [helm_release.traefik]
}

resource "kubernetes_manifest" "middleware_us_header" {
  manifest = yamldecode(file("${path.module}/helm/middleware-us-header.yaml"))

  depends_on = [helm_release.traefik]
}

// Ingress route
resource "kubernetes_manifest" "ingressroute" {
  manifest = yamldecode(file("${path.module}/helm/ingressroute.yaml"))

  depends_on = [
    helm_release.traefik,
    kubernetes_manifest.geoip_middleware,
  ]
}

# resource "kubernetes_manifest" "service" {
#   manifest = yamldecode(file("${path.module}/helm/traefikservice.yaml"))

#   depends_on = [
#     helm_release.traefik,
#     # kubernetes_manifest.geoip_middleware,
#   ]
# }