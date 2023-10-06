variable "location" {
  type    = string
  default = "Canada East"
}

variable "vm_size" {
  type    = string
  default = "Standard_A2_v2"
}

variable "disk_type" {
  type    = string
  default = "Standard_LRS"
}

variable "address_space" {
  type    = string
  default = "10.0.0.0/16"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "billing_code" {
  type    = string
  default = "IT"
}

locals {
  tags = {
    company      = "Communauto"
    billing_code = var.billing_code
    environment  = var.environment
  }
}