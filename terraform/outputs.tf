output "us_vm_ip" {
  value = module.infra_us.public_ip_address
}

output "us_ssh" {
  value = module.infra_us.ssh_connection_string
}


# output "eu_vm_ip" {
#   value = module.infra_eu.public_ip_address
# }

# output "eu_ssh" {
#   value = module.infra_eu.ssh_connection_string
# }


# output "lb_vm_ip" {
#   value = module.infra_lb.public_ip_address
# }

# output "lb_ssh" {
#   value = module.infra_lb.ssh_connection_string
# }
