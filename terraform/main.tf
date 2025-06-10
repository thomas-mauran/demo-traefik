# Azure US
module "azure-us-infra" {
  source = "./modules/azure-k3s"
  
  region = "us"

  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password
  vm_ssh_public_key = var.vm_ssh_public_key
  vm_ssh_private_key_path = var.vm_ssh_private_key_path
  providers = {
    kubernetes = kubernetes.us
    helm       = helm.us
    azurerm    = azurerm
  }
}
# Deploy to US environment
# module "api_deployment_us" {
  # source = "./modules/api-deployment"
  

#   region = "us"
  
#   providers = {
#     kubernetes = kubernetes.us
#     helm       = helm.us
#   }
# }

# # Deploy to EU environment
# module "api_deployment_eu" {
#   source = "./modules/api-deployment"
  
#   region = "eu"
  
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