# API namespace to deploy our app
resource "kubernetes_namespace" "api-namespace" {
  metadata {
    name = "api"
  }
}

# Persistent volume
resource "kubernetes_persistent_volume" "api-pv" {
  metadata {
    name = "api-pv"
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    access_modes = ["ReadWriteOnce"]
    storage_class_name               = "local-path"
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path {
        path = "/mnt/data"
        type = "Directory"
      }
    }
  }
}

# Persistent volume claim
resource "kubernetes_persistent_volume_claim" "api-pvc" {
  metadata {
    name      = "api-pvc"
    namespace = kubernetes_namespace.api-namespace.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    storage_class_name = "local-path"
    volume_name        = kubernetes_persistent_volume.api-pv.metadata[0].name
  }
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
    namespace   = kubernetes_namespace.api-namespace.metadata[0].name
    secret_name = "api-tls"
    common_name = var.host
    issuer_name = "letsencrypt-prod"
  }))

  depends_on = [
    kubernetes_namespace.api-namespace,
    kubernetes_manifest.cert_cluster_issuer,
  ]
}


resource "kubernetes_manifest" "cert_copy_job" {
  count = terraform.workspace == "azure" ? 1 : 0
  manifest = yamldecode(file("${path.module}/helm/cert-manager/job-copy-cert.yaml"))
  depends_on = [
    kubernetes_manifest.cert_certificate,
  ]
}

# We deploy the api
resource "helm_release" "api" {
  name      = "api"
  chart     = "${path.module}/helm"
  namespace = "api"
  values = [
    file("${path.module}/helm/values.yaml")
  ]
  create_namespace = true

  # Override the host value using the host variable
  set = [{
    name  = "ingress.hosts[0].host"
    value = "${var.host}"
  },
  {
    name  = "env.enabled"
    value = true
  },
  {
    name  = "env.name"
    value = var.name
  }]


  depends_on = [
    kubernetes_namespace.api-namespace,
  ]
}

