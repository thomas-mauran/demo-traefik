provider "helm" {
  kubernetes {
    config_paths = [
      "${path.module}/kubeconfigs/kubeconfig-vm-us.yaml",
      "${path.module}/kubeconfigs/kubeconfig-vm-eu.yaml"
    ]
  }
}

provider "kubernetes" {
  alias                  = "us"
  config_path            = "${path.module}/kubeconfigs/kubeconfig-vm-us.yaml"
  config_context         = ""  # Leave empty if not using multiple contexts
}

provider "kubernetes" {
  alias                  = "eu"
  config_path            = "${path.module}/kubeconfigs/kubeconfig-vm-eu.yaml"
  config_context         = ""
}

resource "kubernetes_namespace" "demo_us" {
  provider = kubernetes.us
  metadata {
    name = "demo"
  }
}

resource "kubernetes_namespace" "demo_eu" {
  provider = kubernetes.eu
  metadata {
    name = "demo"
  }
}
