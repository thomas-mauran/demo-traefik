provider "kubernetes" {
  # config_path      = "${path.module}/../../kubeconfigs/kubeconfig-vm-us.yaml"
  config_path      = "~/.kube/config"
}

provider "helm" {
  kubernetes  {
    # config_path      = "${path.module}/../../kubeconfigs/kubeconfig-vm-us.yaml"
    config_path = "~/.kube/config"
  }
}