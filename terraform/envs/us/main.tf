module "api-deployment" {
  source    = "../../modules/api-deployment"
  region = "us"
  
  providers = {
    kubernetes = kubernetes.us
    helm       = helm.us
  }
}