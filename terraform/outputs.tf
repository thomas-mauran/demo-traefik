output "us_vm_ip" {
  value       = terraform.workspace == "azure" ? module.infra_us.public_ip_address : null
  description = "Public IP of the US VM (only in Azure workspace)"
}

output "us_ssh" {
  value       = terraform.workspace == "azure" ? module.infra_us.ssh_connection_string : null
  description = "SSH command for the US VM (only in Azure workspace)"
}

output "eu_vm_ip" {
  value       = terraform.workspace == "azure" ? module.infra_eu.public_ip_address : null
  description = "Public IP of the EU VM (only in Azure workspace)"
}

output "eu_ssh" {
  value       = terraform.workspace == "azure" ? module.infra_eu.ssh_connection_string : null
  description = "SSH command for the EU VM (only in Azure workspace)"
}

output "lb_vm_ip" {
  value       = terraform.workspace == "azure" ? module.infra_lb.public_ip_address : null
  description = "Public IP of the Load Balancer VM (only in Azure workspace)"
}

output "lb_ssh" {
  value       = terraform.workspace == "azure" ? module.infra_lb.ssh_connection_string : null
  description = "SSH command for the Load Balancer VM (only in Azure workspace)"
}
