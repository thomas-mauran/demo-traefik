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

# module "infra_eu" {
#   source = "./modules/azure-k3s"

#   deployment_type  = local.environments.eu.deployment_type
#   region           = local.environments.eu.region
#   host             = var.environments["eu"].host

#   vm_admin_username       = var.vm_admin_username
#   vm_admin_password       = var.vm_admin_password
#   vm_ssh_public_key       = var.vm_ssh_public_key
#   vm_ssh_private_key_path = var.vm_ssh_private_key_path

#   providers = {
#     azurerm    = azurerm
#     kubernetes = kubernetes.eu
#     helm       = helm.eu
#   }
# }

# module "infra_lb" {
#   source = "./modules/azure-k3s"

#   deployment_type  = local.environments.lb.deployment_type
#   region           = local.environments.lb.region
#   host             = var.environments["lb"].host

#   vm_admin_username       = var.vm_admin_username
#   vm_admin_password       = var.vm_admin_password
#   vm_ssh_public_key       = var.vm_ssh_public_key
#   vm_ssh_private_key_path = var.vm_ssh_private_key_path

#   providers = {
#     azurerm    = azurerm
#     kubernetes = kubernetes.lb
#     helm       = helm.lb
#   }
# }

module "api_deployment_us" {
  source = "./modules/api-deployment"
  host   =   var.environments["us"].host

  providers = {
    kubernetes = kubernetes.us
    helm       = helm.us
  }

  depends_on = [module.infra_us]
}

# module "api_deployment_eu" {
#   source = "./modules/api-deployment"
#   host   = var.environments["eu"].host

#   providers = {
#     kubernetes = kubernetes.eu
#     helm       = helm.eu
#   }

#   depends_on = [module.infra_eu]
# }


# module "lb_deployment" {
#   for_each = {
#     for k, v in var.environments : k => v
#     if v.deployment_type == "lb"
#   }

#   source = "./modules/lb-deployment"

#   providers = {
#     kubernetes = kubernetes.lb
#     helm       = helm.lb
#   }

#   depends_on = [ module.infra_lb ]
# }


# --- LOCAL ---
# Deploy to US environment
# module "api_deployment_us" {
#   source = "./modules/api-deployment"
#   host = "api.us"
  
#   providers = {
#     kubernetes = kubernetes.us
#     helm       = helm.us
#   }
# }

# # Deploy to EU environment
# module "api_deployment_eu" {
#   source = "./modules/api-deployment"
#   host = "api.eu"
  
#   providers = {
#     kubernetes = kubernetes.eu
#     helm       = helm.eu
#   }
# }

# # Deploy to LB environment
# module "lb_deployment" {
#   source = "./modules/lb-deployment"
  
#   providers = {
#     kubernetes = kubernetes.lb
#     helm       = helm.lb
#   }
# }