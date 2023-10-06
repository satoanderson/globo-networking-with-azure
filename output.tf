output "public_ip" {
  value       = azurerm_public_ip.web-server.ip_address
  description = "Provides address of public IP address"
}

output "dns" {
  value       = azurerm_public_ip.web-server.domain_name_label
  description = "DNS name of the VM."
}