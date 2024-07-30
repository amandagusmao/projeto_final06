output "public_ip_address" {
  description = "Endereço IP público da VM"
  value       = azurerm_public_ip.student_pip.ip_address
}
