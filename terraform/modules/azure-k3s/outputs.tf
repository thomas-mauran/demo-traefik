output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}

output "vm_name" {
  value = azurerm_virtual_machine.main.name
}

output "ssh_connection_string" {
  value = "ssh ${var.vm_admin_username}@${azurerm_public_ip.main.ip_address}"
}
