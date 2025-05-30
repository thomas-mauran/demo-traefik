# Remove the manual CRD application and let Helm handle it
resource "helm_release" "traefik" {
  name             = "traefik"
  chart            = "oci://ghcr.io/traefik/helm/traefik"
  namespace        = "kube-system"
  values           = [file("${path.module}/helm/values.yaml")]
  create_namespace = true

}

resource "kubernetes_manifest" "endpoint" {
  manifest = yamldecode(file("${path.module}/helm/endpoint.yaml"))

  depends_on = [helm_release.traefik]
}

resource "kubernetes_manifest" "external_us_service" {
  manifest = yamldecode(file("${path.module}/helm/external-us-service.yaml"))

  depends_on = [helm_release.traefik]
}

resource "kubernetes_manifest" "server_transport" {
  manifest = yamldecode(file("${path.module}/helm/servertransport.yaml"))

  depends_on = [helm_release.traefik]
}

resource "kubernetes_manifest" "geoip_middleware" {
  manifest = yamldecode(file("${path.module}/helm/geoip-middleware.yaml"))

  depends_on = [helm_release.traefik]
}

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