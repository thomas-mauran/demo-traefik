# API namespace to deploy our app
resource "azurerm_resource_group" "vm_rg" {
  name     = "${var.region}-group"
  location = "Central US"
}

# Virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.region}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
}

# Subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.vm_rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create the public ip for the vm
resource "azurerm_public_ip" "main" {
  name                = "${var.region}-public-ip"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network interface
resource "azurerm_network_interface" "main" {
  name                = "${var.region}-nic"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Network security group for ssh
resource "azurerm_network_security_group" "main" {
  name                = "${var.region}-nsg"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the sec group with the network interface
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Vm -> ubuntu B1ms (k3s needs at least 2g of ram)
resource "azurerm_virtual_machine" "main" {
  name                  = "${var.region}-vm"
  location              = azurerm_resource_group.vm_rg.location
  resource_group_name   = azurerm_resource_group.vm_rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1ms"

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = var.vm_admin_username
    admin_password = var.vm_admin_password

    custom_data = filebase64("${path.module}/cloud-inits/regional-server.sh")

  }
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
      key_data = var.vm_ssh_public_key
    }
  }
}

resource "null_resource" "install_k3s" {
  depends_on = [azurerm_virtual_machine.main]

  connection {
    type        = "ssh"
    user        = var.vm_admin_username
    host        = azurerm_public_ip.main.ip_address
    private_key = file(var.vm_ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --tls-san ${azurerm_public_ip.main.ip_address}"
    ]
  }
}

resource "null_resource" "get_kubeconfig" {
  depends_on = [null_resource.install_k3s]

  connection {
    type        = "ssh"
    user        = var.vm_admin_username
    host        = azurerm_public_ip.main.ip_address
    private_key = file(var.vm_ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for kubeconfig...'",
      "for i in {1..24}; do [ -f /etc/rancher/k3s/k3s.yaml ] && break || sleep 5; done",
      "sudo cp /etc/rancher/k3s/k3s.yaml /tmp/kubeconfig.yaml",
      "sudo chown ${var.vm_admin_username}:${var.vm_admin_username} /tmp/kubeconfig.yaml"
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ./kubeconfigs/azure &&
      scp -i ${var.vm_ssh_private_key_path} -o StrictHostKeyChecking=no ${var.vm_admin_username}@${azurerm_public_ip.main.ip_address}:/tmp/kubeconfig.yaml ./kubeconfigs/azure/kubeconfig-vm-${var.region}.yaml
    EOT
  }
}
