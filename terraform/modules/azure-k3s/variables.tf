# Region of the cluster
variable "region" {
  type = string

  validation {
    condition     = var.region == "us" || var.region == "eu"
    error_message = "Region must be either 'us' or 'eu'."
  }
}

variable "deployment_type" {
  type = string

  validation {
    condition     = var.deployment_type == "api" || var.deployment_type == "lb"
    error_message = "deployment_type must be an api or a lb"
  }
}

variable "host" {
  type = string
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