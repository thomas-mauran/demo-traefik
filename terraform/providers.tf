locals {
  kubeconfigs = {
    local = {
      us = "./kubeconfigs/local/kubeconfig-vm-us.yaml"
      eu = "./kubeconfigs/local/kubeconfig-vm-eu.yaml"
      lb = "./kubeconfigs/local/kubeconfig-vm-lb.yaml"
    }
    azure = {
      us = "./kubeconfigs/azure/kubeconfig-vm-us.yaml"
      eu = "./kubeconfigs/azure/kubeconfig-vm-us.yaml"
      lb = "./kubeconfigs/azure/kubeconfig-vm-us.yaml"
    }
  }

  current_workspace = terraform.workspace
}

# --- Kubernetes Providers ---
provider "kubernetes" {
  alias       = "us"
  config_path = local.kubeconfigs[local.current_workspace]["us"]
}

provider "kubernetes" {
  alias       = "eu"
  config_path = local.kubeconfigs[local.current_workspace]["eu"]
}

provider "kubernetes" {
  alias       = "lb"
  config_path = local.kubeconfigs[local.current_workspace]["lb"]
}

# --- Helm Providers ---
provider "helm" {
  alias = "us"
  kubernetes = {
    config_path = local.kubeconfigs[local.current_workspace]["us"]
  }
}

provider "helm" {
  alias = "eu"
  kubernetes = {
    config_path = local.kubeconfigs[local.current_workspace]["eu"]
  }
}

provider "helm" {
  alias = "lb"
  kubernetes = {
    config_path = local.kubeconfigs[local.current_workspace]["lb"]
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}