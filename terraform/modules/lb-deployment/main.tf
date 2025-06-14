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

# Cert manager and generation of the certs if we are in azure mode
resource "helm_release" "cert_manager" {
  count      = terraform.workspace == "azure" ? 1 : 0
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v1.18.0"
  create_namespace = true
}

resource "kubernetes_manifest" "cert_cluster_issuer" {
  count = terraform.workspace == "azure" ? 1 : 0
  manifest = yamldecode(templatefile("${path.module}/helm/cert-manager/cluster-issuer.tpl.yaml", {
    host = var.host
  }))
  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "cert_certificate" {
  count = terraform.workspace == "azure" ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/helm/cert-manager/certificate.tpl.yaml", {
    namespace   = "default"
    secret_name = "api-tls"
    common_name = var.host
    issuer_name = "letsencrypt-prod"
  }))

  depends_on = [
    kubernetes_manifest.cert_cluster_issuer,
  ]
}


// External services
resource "kubernetes_manifest" "external_us_service" {
  manifest = yamldecode(templatefile("${path.module}/helm/external-service.tpl.yaml", {
    region = "us"
    url = terraform.workspace == "azure"  ? "us.${var.global_host}" : "api.us"
  }))
  depends_on = [helm_release.traefik]
}

resource "kubernetes_manifest" "external_eu_service" {
  manifest = yamldecode(templatefile("${path.module}/helm/external-service.tpl.yaml", {
    region = "eu"
    url = terraform.workspace == "azure" ? "eu.${var.global_host}" : "api.eu"
  }))
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

// Ingress route depending on the workspace azure or local
resource "kubernetes_manifest" "ingressroute" {
  manifest = yamldecode(templatefile(
    terraform.workspace == "azure" ? "${path.module}/helm/ingressroute-geoip.tpl.yaml" : "${path.module}/helm/ingressroute-roundrobin.tpl.yaml",
    {
      global_host = var.global_host
    }
  ))

  depends_on = [
    helm_release.traefik,
    kubernetes_manifest.geoip_middleware,
  ]
}
