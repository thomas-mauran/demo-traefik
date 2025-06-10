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