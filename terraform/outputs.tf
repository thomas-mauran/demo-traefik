output "us_vm_ip" {
  value = module.azure-us-infra.public_ip_address
}

output "us_ssh" {
  value = module.azure-us-infra.ssh_connection_string
}
