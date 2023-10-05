terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">=0.49.1"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "azurerm" {
  features {}
}

##################################################################################
# DATA
##################################################################################

data "azurerm_subnet" "public_subnet1" {
  name                 = "public_subnet1"
  resource_group_name  = azurerm_resource_group.web-server.name
  virtual_network_name = azurerm_virtual_network.web-server.name
}

##################################################################################
# LOCALS
##################################################################################

locals {
  custom_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt install -y nginx
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server on Azure!</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}

##################################################################################
# RESOURCES
##################################################################################

# RESOURCE GROUP #

resource "azurerm_resource_group" "web-server" {
  name     = "Terraform-Getting-Started"
  location = "Canada East"
}

# NETWORKING #

resource "azurerm_network_security_group" "web-server" {
  name                = "web-server-nsg"
  location            = azurerm_resource_group.web-server.location
  resource_group_name = azurerm_resource_group.web-server.name

  security_rule {
    name                       = "Allow-HTTP"
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

resource "azurerm_virtual_network" "web-server" {
  name                = "web-server"
  location            = azurerm_resource_group.web-server.location
  resource_group_name = azurerm_resource_group.web-server.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "public_subnet1"
    address_prefix = "10.0.1.0/24"
  }
}

# INSTANCES #

resource "azurerm_public_ip" "web-server" {
  name                = "webServerPIP"
  resource_group_name = azurerm_resource_group.web-server.name
  location            = azurerm_resource_group.web-server.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "web-server" {
  name                = "web-server-nic"
  location            = azurerm_resource_group.web-server.location
  resource_group_name = azurerm_resource_group.web-server.location

  ip_configuration {
    name                          = "public-web-server"
    subnet_id                     = data.azurerm_subnet.public_subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web-server.id
  }
}

resource "azurerm_linux_virtual_machine" "web-server" {
  name                  = "Web-Server"
  resource_group_name   = azurerm_resource_group.web-server.name
  location              = azurerm_resource_group.web-server.location
  size                  = "Standard_A2_v2"
  admin_username        = "adminsato"
  network_interface_ids = [azurerm_network_interface.web-server.id]
  admin_password        = "Simba1102"
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "None"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  user_data = base64encode(local.custom_data)
}
