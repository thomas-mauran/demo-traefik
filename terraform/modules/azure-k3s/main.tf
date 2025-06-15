locals {
  hostname = "vm-${var.region}-${var.deployment_type}"
}

# API namespace to deploy our app
resource "azurerm_resource_group" "vm_rg" {
  name     = "${var.region}-${var.deployment_type}-group"
  location = var.region == "us" ? "centralus" : "westeurope"
}

# Virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.region}-${var.deployment_type}-network"
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
  name                = "${var.region}-${var.deployment_type}-public-ip"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network interface
resource "azurerm_network_interface" "main" {
  name                = "${var.region}-${var.deployment_type}-nic"
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
  name                = "${var.region}-${var.deployment_type}-nsg"
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

  security_rule {
    name                       = "K8s-API"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
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
  name                = "vm-${var.region}-${var.deployment_type}"
  location              = azurerm_resource_group.vm_rg.location
  resource_group_name   = azurerm_resource_group.vm_rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1ms"

  delete_os_disk_on_termination     = true
  delete_data_disks_on_termination  = true

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
    computer_name  = "vm-${var.region}-${var.deployment_type}"
    admin_username = var.vm_admin_username
    admin_password = var.vm_admin_password
    custom_data = base64encode(templatefile("${path.module}/cloud-inits/install_k3s_with_tls.tftpl", {
      PUBLIC_IP = azurerm_public_ip.main.ip_address
      DEPLOYMENT_TYPE = var.deployment_type
      REGION     = var.region
    }))
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
      key_data = var.vm_ssh_public_key
    }
  }
}

resource "null_resource" "wait_for_kubeconfig" {
  depends_on = [azurerm_virtual_machine.main]

  connection {
    type        = "ssh"
    user        = var.vm_admin_username
    host        = azurerm_public_ip.main.ip_address
    private_key = file(var.vm_ssh_private_key_path)
  }

    provisioner "remote-exec" {
      inline = [
        <<-EOF
        bash -c '
        echo "Waiting for /etc/rancher/k3s/k3s.yaml to be created..."
        for i in $(seq 1 24); do
          if [ -f /etc/rancher/k3s/k3s.yaml ]; then
            echo "k3s.yaml found!"
            break
          else
            echo "Waiting for k3s.yaml... attempt $i"
            sleep 5
          fi
        done
        if [ ! -f /etc/rancher/k3s/k3s.yaml ]; then
          echo "ERROR: /etc/rancher/k3s/k3s.yaml not found after waiting period"
          exit 1
        fi
        sed "s|https://127.0.0.1:6443|https://${azurerm_public_ip.main.ip_address}:6443|" /etc/rancher/k3s/k3s.yaml > /tmp/kubeconfig.yaml
        sudo chown ${var.vm_admin_username}:${var.vm_admin_username} /tmp/kubeconfig.yaml
        '
        EOF
      ]
    }
}

resource "null_resource" "generate_remote_ssl_cert" {
  depends_on = [null_resource.wait_for_kubeconfig]

  connection {
    type        = "ssh"
    user        = var.vm_admin_username
    host        = azurerm_public_ip.main.ip_address
    private_key = file(var.vm_ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "echo 'Creating cert.conf with subjectAltName...'",

      "cat <<EOF > /tmp/cert.conf\n[req]\ndistinguished_name=req\n[ext]\nsubjectAltName=DNS:${var.region}.${var.deployment_type}.yourdomain.com\nEOF",

      "echo 'Creating directory for certs...'",
      "sudo mkdir -p /mnt/data",

      "echo 'Generating self-signed SSL cert...'",
      "sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /mnt/data/key.pem -out /mnt/data/cert.pem -subj \"/CN=${var.host}.yourdomain.com/O=AzureTerraformCert\" -extensions ext -config /tmp/cert.conf",

      "echo 'Changing ownership of certs...'",
      "sudo chown ${var.vm_admin_username}:${var.vm_admin_username} /mnt/data/*"
    ]


  }
}


resource "null_resource" "fetch_kubeconfig" {
  depends_on = [null_resource.wait_for_kubeconfig]

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ./kubeconfigs/azure &&
      scp -i ${var.vm_ssh_private_key_path} -o StrictHostKeyChecking=no ${var.vm_admin_username}@${azurerm_public_ip.main.ip_address}:/tmp/kubeconfig.yaml ./kubeconfigs/azure/kubeconfig-vm-${var.region}-${var.deployment_type}.yaml
    EOT
  }
}
