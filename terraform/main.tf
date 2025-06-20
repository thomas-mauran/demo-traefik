# Azure US
module "infra_us" {
  source = "./modules/azure-k3s"

  deployment_type  = local.environments.us.deployment_type
  region           = local.environments.us.region
  host             = var.environments["us"].host

  vm_admin_username       = var.vm_admin_username
  vm_admin_password       = var.vm_admin_password
  vm_ssh_public_key       = var.vm_ssh_public_key
  vm_ssh_private_key_path = var.vm_ssh_private_key_path

  providers = {
    azurerm    = azurerm
    kubernetes = kubernetes.us
    helm       = helm.us
  }
}

module "infra_eu" {
  source = "./modules/azure-k3s"

  deployment_type  = local.environments.eu.deployment_type
  region           = local.environments.eu.region
  host             = var.environments["eu"].host

  vm_admin_username       = var.vm_admin_username
  vm_admin_password       = var.vm_admin_password
  vm_ssh_public_key       = var.vm_ssh_public_key
  vm_ssh_private_key_path = var.vm_ssh_private_key_path

  providers = {
    azurerm    = azurerm
    kubernetes = kubernetes.eu
    helm       = helm.eu
  }
}

module "infra_lb" {
  source = "./modules/azure-k3s"

  deployment_type  = local.environments.lb.deployment_type
  region           = local.environments.lb.region
  host             = var.environments["lb"].host

  vm_admin_username       = var.vm_admin_username
  vm_admin_password       = var.vm_admin_password
  vm_ssh_public_key       = var.vm_ssh_public_key
  vm_ssh_private_key_path = var.vm_ssh_private_key_path

  providers = {
    azurerm    = azurerm
    kubernetes = kubernetes.lb
    helm       = helm.lb
  }
}

module "api_deployment_us" {
  source = "./modules/api-deployment"
  host   =   var.environments["us"].host
  name   = "us"
  providers = {
    kubernetes = kubernetes.us
    helm       = helm.us
  }

  depends_on = [module.infra_us]
}

module "api_deployment_eu" {
  source = "./modules/api-deployment"
  host   = var.environments["eu"].host
  name   = "eu"
  providers = {
    kubernetes = kubernetes.eu
    helm       = helm.eu
  }

  depends_on = [module.infra_eu]
}


module "lb_deployment" {
  for_each = {
    for k, v in var.environments : k => v
    if v.deployment_type == "lb"
  }

  global_host = var.global_host
  source = "./modules/lb-deployment"
  host = var.environments["lb"].host

  providers = {
    kubernetes = kubernetes.lb
    helm       = helm.lb
  }

  depends_on = [ module.infra_lb ]
}

# --- LOCAL ---
# Deploy to US environment
module "api_deployment_us_local" {
  source = "./modules/api-deployment"
  host = "api.us"
  name = "us"
  providers = {
    kubernetes = kubernetes.us
    helm       = helm.us
  }
}

# Deploy to EU environment
module "api_deployment_eu_local" {
  source = "./modules/api-deployment"
  host = "api.eu"
  name = "eu"
  
  providers = {
    kubernetes = kubernetes.eu
    helm       = helm.eu
  }
}

# Deploy to LB environment
module "lb_deployment_local" {
  source = "./modules/lb-deployment"
  global_host = var.global_host
  host             = var.environments["lb"].host

  providers = {
    kubernetes = kubernetes.lb
    helm       = helm.lb
  }
}

# Monitoring
module "monit_us" {
  source = "./modules/monitoring"

  hosted_prometheus_metrics_url = var.hosted_prometheus_metrics_url
  hosted_prometheus_username = var.hosted_prometheus_username
  hosted_prometheus_token = var.hosted_prometheus_token

  providers = {
    kubernetes = kubernetes.us
    helm       = helm.us
  }
}

module "monit_eu" {
  source = "./modules/monitoring"

  hosted_prometheus_metrics_url = var.hosted_prometheus_metrics_url
  hosted_prometheus_username = var.hosted_prometheus_username
  hosted_prometheus_token = var.hosted_prometheus_token
  
  providers = {
    kubernetes = kubernetes.eu
    helm       = helm.eu
  }
}
