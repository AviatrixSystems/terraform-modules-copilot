terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

resource "azurerm_resource_group" "aviatrix_copilot_rg" {
  location = var.location
  name     = "${var.copilot_name}-rg"
}

resource "azurerm_virtual_network" "aviatrix_copilot_vnet" {
  address_space       = [var.copilot_vnet_cidr]
  location            = var.location
  name                = "${var.copilot_name}-vnet"
  resource_group_name = azurerm_resource_group.aviatrix_copilot_rg.name
}

resource "azurerm_subnet" "aviatrix_copilot_subnet" {
  name                 = "${var.copilot_name}-subnet"
  resource_group_name  = azurerm_resource_group.aviatrix_copilot_rg.name
  virtual_network_name = azurerm_virtual_network.aviatrix_copilot_vnet.name
  address_prefixes     = [var.copilot_subnet_cidr]
}

resource "azurerm_public_ip" "aviatrix_copilot_public_ip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.aviatrix_copilot_rg.location
  name                = "${var.copilot_name}-public-ip"
  resource_group_name = azurerm_resource_group.aviatrix_copilot_rg.name
}

resource "azurerm_network_security_group" "aviatrix_copilot_nsg" {
  location            = azurerm_resource_group.aviatrix_copilot_rg.location
  name                = "${var.copilot_name}-security-group"
  resource_group_name = azurerm_resource_group.aviatrix_copilot_rg.name

  dynamic "security_rule" {
    for_each = var.allowed_cidrs
    content {
      access                     = "Allow"
      direction                  = "Inbound"
      name                       = security_rule.key
      priority                   = security_rule.value["priority"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = "*"
      destination_port_ranges    = security_rule.value["ports"]
      source_address_prefixes    = security_rule.value["cidrs"]
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface" "aviatrix_copilot_nic" {
  location            = azurerm_resource_group.aviatrix_copilot_rg.location
  name                = "${var.copilot_name}-network-interface-card"
  resource_group_name = azurerm_resource_group.aviatrix_copilot_rg.name
  ip_configuration {
    name                          = "${var.copilot_name}-nic"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.aviatrix_copilot_subnet.id
    public_ip_address_id          = azurerm_public_ip.aviatrix_copilot_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.aviatrix_copilot_nic.id
  network_security_group_id = azurerm_network_security_group.aviatrix_copilot_nsg.id
}

resource "azurerm_linux_virtual_machine" "aviatrix_copilot_vm" {
  admin_username                  = var.copilot_virtual_machine_admin_username
  admin_password                  = var.copilot_virtual_machine_admin_password
  name                            = "${var.copilot_name}-vm"
  disable_password_authentication = false
  location                        = azurerm_resource_group.aviatrix_copilot_rg.location
  network_interface_ids           = [azurerm_network_interface.aviatrix_copilot_nic.id]
  resource_group_name             = azurerm_resource_group.aviatrix_copilot_rg.name
  size                            = var.copilot_virtual_machine_size
  //disk
  os_disk {
    name                 = "aviatrix-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "aviatrix-copilot"
    publisher = "aviatrix-systems"
    sku       = "avx-cplt-byol-01"
    version   = "latest"
  }

  plan {
    name      = "avx-cplt-byol-01"
    product   = "aviatrix-copilot"
    publisher = "aviatrix-systems"
  }
}
