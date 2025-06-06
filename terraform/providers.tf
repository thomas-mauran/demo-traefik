# --- Kube Providers ---
provider "kubernetes" {
  alias       = "us"
  config_path = "${path.module}/kubeconfigs/kubeconfig-vm-us.yaml"

}

provider "kubernetes" {
  alias       = "eu"
  config_path = "${path.module}/kubeconfigs/kubeconfig-vm-eu.yaml"
}

# --- Helm Providers ---
provider "helm" {
  alias = "eu"
  kubernetes = {
    config_path = "${path.module}/kubeconfigs/kubeconfig-vm-eu.yaml"
  }
}

provider "helm" {
  alias = "us"
  kubernetes = {
    config_path = "${path.module}/kubeconfigs/kubeconfig-vm-us.yaml"
  }
}