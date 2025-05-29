variable "region" {
  type = string
}

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



resource "helm_release" "api" {
  name       = "api"
  chart      = "${path.module}/helm"
  namespace = kubernetes_namespace.api-namespace.metadata[0].name
}
