# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "5151c4b1-0eb2-4a3f-99f7-990391411d0d"
  client_id = "5b9f96c5-744f-4757-a06e-ab5141572fba"
  client_secret = "X_F8Q~ilb4LbtaAPEapBHqg7ufnPk5kW4B3Z3ceh"
  tenant_id = "88a6e1ac-118a-46bf-8064-17978db31ec3"
    
}
terraform {
  backend "azurerm" {
    storage_account_name = "rsgsa"
    container_name       = "tfstatecontainer"
    key                  = "prod.terraform.tfstatecontainer"

    # rather than defining this inline, the Access Key can also be sourced
    # from an Environment Variable - more information is available below.
    access_key = "3S/IXj4Urb0ZPT6pWsBJh2wmeDRNHlD+H/d6Le9jrHWxZ3IDZXCsDCvxrYehmYt28id0PTCuchJC+ASt1n3Ygw=="
  }
}

resource "azurerm_resource_group" "rg"{
    name = "${var.rgname}"
    location = "${var.rglocation}"
    }

resource "azurerm_virtual_network" "vnet2" {
  name                = "${var.prefix}VNET"
  location            = "${azurerm_resource_group.rg.location}"
resource_group_name   = "${azurerm_resource_group.rg.name}"
  address_space       = ["${var.vnet_cidr_prefix}"]
}

 resource "azurerm_subnet" "subnet" {
  name                 = "SBNT"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet2.name}"
  address_prefixes     = ["${var.subnet_cidr_prefix}"]
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "${var.prefix}_NSG"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "nsg2_ass" {
  subnet_id                 = "${azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg2.id}"
}

resource "azurerm_network_interface" "nic1" {
  name                = "${var.prefix}_NIC"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VM3" {
  name                = "${var.prefix}-VM"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}