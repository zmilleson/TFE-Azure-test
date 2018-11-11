variable "rg_name" {
    default = "milleson_challenge06"
}

variable "location" {
    default = "eastus2"
}

module "network" {
    source              = "Azure/network/azurerm"
    version             = "2.0.0"
    resource_group_name = "${var.rg_name}"
    location            = "${var.location}"

    tags = {
        environment = "testing"
        Owner       = "Zach Milleson"
    }
}

module "windowsservers" {
    source                          = "Azure/compute/azurerm"
    version                         = "1.1.7"
    resource_group_name             = "${var.rg_name}"
    location                        = "${var.location}"
    admin_password                  = "P@ssword12345!"
    vm_os_simple                    = "WindowsServer"
    nb_public_ip                    = 1
    public_ip_address_allocation    = "dynamic"
    public_ip_dns                   = ["millez"]
    vnet_subnet_id                  = "${module.network.vnet_subnets[0]}"
    delete_os_disk_on_termination   = "true"
}