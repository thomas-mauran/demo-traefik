variable "azure_subscription_id" {
  type = string
  description = "Your azure subscription id"
}

variable "vm_admin_username" {
  type = string
}

variable "vm_admin_password" {
  type = string
}

variable "vm_ssh_public_key" {
  type        = string
  description = "The public SSH key for the VM"
}

variable "vm_ssh_private_key_path" {
  type = string
}

variable "global_host"{
  type = string
  default = "localhost"
}
variable "environments" {
  type = map(object({
    region          = string
    host            = string
    deployment_type = string
    providers       = object({
      kubernetes = string
      helm       = string
    })
  }))

  default = {
    us = {
      region          = "us"
      host            = "us.thomas-mauran.com"
      deployment_type = "api"
      providers = {
        kubernetes = "us"
        helm       = "us"
      }
    }
    eu = {
      region          = "eu"
      host            = "eu.thomas-mauran.com"
      deployment_type = "api"
      providers = {
        kubernetes = "eu"
        helm       = "eu"
      }
    }
    lb = {
      region          = "eu"
      host            = "lb.thomas-mauran.com"
      deployment_type = "lb"
      providers = {
        kubernetes = "lb"
        helm       = "lb"
      }
    }
  }
}

# --- Monitoring ---

variable "hosted_prometheus_token" {
  description = "The token for hosted Prometheus"
  type        = string
  sensitive   = true
}

variable "hosted_prometheus_metrics_url" {
  description = "The URL for hosted Prometheus metrics endpoint"
  type        = string
}

variable "hosted_prometheus_username" {
  description = "The username for hosted Prometheus"
  type        = string
}