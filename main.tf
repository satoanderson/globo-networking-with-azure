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
    name                       = "Allow HTTP"
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

# ROUTING #

# SECURITY GROUPS #
# Nginx security group 

# HTTP access from anywhere

# outbound internet access

# INSTANCES #

#  user_data = <<EOF
#! /bin/bash
#sudo amazon-linux-extras install -y nginx1
#sudo service nginx start
#sudo rm /usr/share/nginx/html/index.html
#echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
#EOF

#

