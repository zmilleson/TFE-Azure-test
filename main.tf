# Provider and terraform versions
provider "azurerm" {
    version = "= 1.4"
}

terraform {
    required_version = "= 0.11.7"
}

# Variables
variable "name" {
    default = "mille31"
}
variable "location" {
    default = "eastus2"
}

variable "vmcount" {
    default = 1
}

# Resources
resource "azurerm_resource_group" "main" {
    name        = "${var.name}-rg"
    location    = "${var.location}"

    tags {
        Owner       = "Zach Milleson"
        environment = "testing"
    }
}

resource "azurerm_virtual_network" "main" {
    name                = "${var.name}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"

    tags {
        Owner       = "Zach Milleson"
        environment = "testing"
    }
}

resource "azurerm_subnet" "main" {
    name                    = "${var.name}-subnet"
    resource_group_name     = "${azurerm_resource_group.main.name}"
    virtual_network_name    = "${azurerm_virtual_network.main.name}"
    address_prefix          = "10.0.1.0/24"
}

resource "azurerm_network_interface" "main" {
    name                = "${var.name}-nic${count.index}"
    location            = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"
    count               = "${var.vmcount}"

    ip_configuration {
        name                            = "config1"
        subnet_id                       = "${azurerm_subnet.main.id}"
        private_ip_address_allocation   = "dynamic"
        public_ip_address_id            = "${element(azurerm_public_ip.main.*.id, count.index)}"

    }
}

resource "azurerm_virtual_machine" "main" {
    name                    = "${var.name}-vm${count.index}"
    location                = "${azurerm_resource_group.main.location}"
    resource_group_name     = "${azurerm_resource_group.main.name}"
    network_interface_ids   = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
    vm_size                 = "Standard_A4_v2"
    count                   = "${var.vmcount}"

    storage_image_reference {
        publisher   = "MicrosoftWindowsServer"
        offer       = "WindowsServer"
        sku         = "2016-Datacenter"
        version     = "latest"
    }

    storage_os_disk {
        name                = "${var.name}vm${count.index}-osdisk"
        caching             = "ReadWrite"
        create_option       = "FromImage"
        managed_disk_type   = "Standard_LRS"
    }

    os_profile {
        computer_name       = "${var.name}vm${count.index}"
        admin_username      = "testadmin"
        admin_password      = "Password1234!"
    }

    os_profile_windows_config {}

    tags {
        Owner       = "Zach Milleson"
        environment = "testing"
    }
}

resource "azurerm_public_ip" "main" {
    name                            = "${var.name}-pubip${count.index}"
    location                        = "${azurerm_resource_group.main.location}"
    resource_group_name             = "${azurerm_resource_group.main.name}"
    public_ip_address_allocation    = "static"
    domain_name_label               = "aheadchallenge0${count.index}"
    count                           = "${var.vmcount}"
}

output "private-ip" {
  value = "${azurerm_network_interface.main.*.private_ip_address}"
  description   = "Private IP Address"
}

output "public-ip" {
  value = "${azurerm_public_ip.main.*.ip_address}"
  description   = "Public IP Address"
}

