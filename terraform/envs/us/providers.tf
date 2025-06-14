provider "kubernetes" {
  alias       = "us"
  config_path = "${path.module}/kubeconfigs/local/kubeconfig-vm-us.yaml"
}

provider "helm" {
  alias = "us"
  kubernetes {
    config_path = "${path.module}/kubeconfigs/local/kubeconfig-vm-us.yaml"
  }
}
