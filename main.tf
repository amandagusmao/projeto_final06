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

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
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
    web_ip       = azurerm_public_ip.student_pip.ip_address,
    web_user     = var.vm_username,
    web_password = var.vm_password
  })
  filename = "inventory.ini"
}
