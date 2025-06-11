locals {
  environments = {
    us = {
      region          = "us"
      deployment_type = "api"
      provider_alias  = "us"
    }
    eu = {
      region          = "eu"
      deployment_type = "api"
      provider_alias  = "eu"
    }
    lb = {
      region          = "eu"
      deployment_type = "lb"
      provider_alias  = "lb"
    }
  }
}

# Kubernetes kubeconfig paths per workspace and env
locals {
  kubeconfigs = {
    local = {
      us = "./kubeconfigs/local/kubeconfig-vm-us.yaml"
      eu = "./kubeconfigs/local/kubeconfig-vm-eu.yaml"
      lb = "./kubeconfigs/local/kubeconfig-vm-lb.yaml"
    }
    azure = {
      us = "./kubeconfigs/azure/kubeconfig-vm-us-api.yaml"
      eu = "./kubeconfigs/azure/kubeconfig-vm-eu-api.yaml"
      lb = "./kubeconfigs/azure/kubeconfig-vm-eu-lb.yaml"
    }
  }
  
  current_workspace = terraform.workspace
}


# AzureRM providers (add subscription IDs per alias)
provider "azurerm" {
  features         {}
  subscription_id = var.azure_subscription_id
}

# Kubernetes providers with aliases and kubeconfig paths
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

# Helm providers with aliases referencing Kubernetes providers
provider "helm" {
  alias      = "us"
  kubernetes = {
    config_path = local.kubeconfigs[local.current_workspace]["us"]
  }
}

provider "helm" {
  alias      = "eu"
  kubernetes = {
    config_path = local.kubeconfigs[local.current_workspace]["eu"]
  }
}

provider "helm" {
  alias      = "lb"
  kubernetes = {
    config_path = local.kubeconfigs[local.current_workspace]["lb"]
  }
}
