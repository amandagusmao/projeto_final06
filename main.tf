resource "azurerm_resource_group" "student_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "student_vnet" {
  name                = "student-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.student_rg.location
  resource_group_name = azurerm_resource_group.student_rg.name
}

resource "azurerm_subnet" "student_subnet" {
  name                 = "student-subnet"
  resource_group_name  = azurerm_resource_group.student_rg.name
  virtual_network_name = azurerm_virtual_network.student_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "student_nsg" {
  name                = "student-nsg"
  location            = azurerm_resource_group.student_rg.location
  resource_group_name = azurerm_resource_group.student_rg.name
}

resource "azurerm_public_ip" "student_pip" {
  name                = "student-pip"
  location            = azurerm_resource_group.student_rg.location
  resource_group_name = azurerm_resource_group.student_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "student_nic" {
  name                = "student-nic"
  location            = azurerm_resource_group.student_rg.location
  resource_group_name = azurerm_resource_group.student_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.student_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.student_pip.id
  }
}

resource "azurerm_virtual_machine" "student_vm" {
  name                  = "student-vm"
  location              = azurerm_resource_group.student_rg.location
  resource_group_name   = azurerm_resource_group.student_rg.name
  network_interface_ids = [azurerm_network_interface.student_nic.id]
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "student_os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "student-vm"
    admin_username = var.vm_username
    admin_password = var.vm_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "local_file" "inventory" {
  content = templatefile("inventory.tpl", {
    host_ip = azurerm_virtual_machine.student_vm.public_ip_address,
  })
  filename = "inventory.ini"
}
