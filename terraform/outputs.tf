output "us_vm_ip" {
  value = module.azure_us_infra.public_ip_address
}

output "us_ssh" {
  value = module.azure_us_infra.ssh_connection_string
}
