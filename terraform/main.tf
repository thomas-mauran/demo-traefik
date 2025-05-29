# Deploy to US environment
module "api_deployment_us" {
  source = "./modules/api-deployment"
  
  region = "us"
  
  providers = {
    kubernetes = kubernetes.us
    helm       = helm.us
  }
}

# Deploy to EU environment
module "api_deployment_eu" {
  source = "./modules/api-deployment"
  
  region = "eu"
  
  providers = {
    kubernetes = kubernetes.eu
    helm       = helm.eu
  }
}