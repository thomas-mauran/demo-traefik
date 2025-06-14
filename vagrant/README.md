# Vagrant Virtual Machine

We are gonna use Vagrant to create a virtual machine that will run the demo application on 3 nodes.

- a EU node
- a US node
- a Loadbalancing node

## Setup

1. Install [Vagrant](https://www.vagrantup.com/downloads) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
2. Install a virtualization provider, such as [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
3. Start the Vagrant VM:
   ```bash
   cd vagrant
   vagrant up
   ```
As defined in the `Vagrantfile`. This will create the 3 VMs: `vm-eu`, `vm-us`, and `vm-lb`.
The command will also copy the kubeconfig files from the vm to the terraform/kubeconfigs directory.

4. SSH into a VM:
   ```bash
   vagrant ssh vm-us
   ```