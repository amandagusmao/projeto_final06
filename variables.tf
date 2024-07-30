variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
  default     = "student-rg"
}

variable "location" {
  description = "Localização dos recursos"
  type        = string
  default     = "eastus"
}

variable "vm_username" {
  description = "Nome de usuário da VM"
  type        = string
  default     = "azureuser"
}

variable "vm_password" {
  description = "Senha da VM"
  type        = string
  default     = "Azureuser1@"
  sensitive   = true
}
