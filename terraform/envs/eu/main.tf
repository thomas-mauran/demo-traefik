module "api-deployment" {
  source    = "../../modules/api-deployment"
  region = "eu"
  
  providers = {
    kubernetes = kubernetes.eu
    helm       = helm.eu
  }
}