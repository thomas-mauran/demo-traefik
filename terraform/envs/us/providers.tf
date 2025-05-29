provider "kubernetes" {
  alias       = "us"
  config_path = "${path.module}/kubeconfigs/kubeconfig-vm-us.yaml"
}

provider "helm" {
  alias = "us"
  kubernetes {
    config_path = "${path.module}/kubeconfigs/kubeconfig-vm-us.yaml"
  }
}
