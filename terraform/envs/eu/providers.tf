provider "kubernetes" {
  alias       = "eu"
  config_path = "${path.module}/kubeconfigs/local/kubeconfig-vm-us.yaml"
}

provider "helm" {
  alias = "eu"
  kubernetes {
    config_path = "${path.module}/kubeconfigs/local/kubeconfig-vm-us.yaml"
  }
}
