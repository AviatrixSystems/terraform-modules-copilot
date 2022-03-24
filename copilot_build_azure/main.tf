resource "azurerm_resource_group" "aviatrix_copilot_rg" {
  count    = var.use_existing_vnet == false ? 1 : 0
  location = var.location
  name     = "${var.copilot_name}-rg"
}

resource "azurerm_virtual_network" "aviatrix_copilot_vnet" {
  count               = var.use_existing_vnet == false ? 1 : 0
  address_space       = [var.vnet_cidr]
  location            = var.location
  name                = "${var.copilot_name}-vnet"
  resource_group_name = azurerm_resource_group.aviatrix_copilot_rg[0].name
}

resource "azurerm_subnet" "aviatrix_copilot_subnet" {
  count                = var.use_existing_vnet == false ? 1 : 0
  name                 = "${var.copilot_name}-subnet"
  resource_group_name  = azurerm_resource_group.aviatrix_copilot_rg[0].name
  virtual_network_name = azurerm_virtual_network.aviatrix_copilot_vnet[0].name
  address_prefixes     = [var.subnet_cidr]
}

resource "azurerm_public_ip" "aviatrix_copilot_public_ip" {
  allocation_method   = "Static"
  location            = var.location
  name                = "${var.copilot_name}-public-ip"
  resource_group_name = var.use_existing_vnet == false ? azurerm_resource_group.aviatrix_copilot_rg[0].name : var.resource_group_name
}

resource "azurerm_network_security_group" "aviatrix_copilot_nsg" {
  location            = var.location
  name                = "${var.copilot_name}-security-group"
  resource_group_name = var.use_existing_vnet == false ? azurerm_resource_group.aviatrix_copilot_rg[0].name : var.resource_group_name

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
  location            = var.location
  name                = "${var.copilot_name}-network-interface-card"
  resource_group_name = var.use_existing_vnet == false ? azurerm_resource_group.aviatrix_copilot_rg[0].name : var.resource_group_name
  ip_configuration {
    name                          = "${var.copilot_name}-nic"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.use_existing_vnet == false ? azurerm_subnet.aviatrix_copilot_subnet[0].id : var.subnet_id
    public_ip_address_id          = azurerm_public_ip.aviatrix_copilot_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.aviatrix_copilot_nic.id
  network_security_group_id = azurerm_network_security_group.aviatrix_copilot_nsg.id
}

resource "tls_private_key" "key_pair_material" {
  count     = var.add_ssh_key ? (var.use_existing_ssh_key == false ? 1 : 0) : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "aviatrix_copilot_vm" {
  count                           = var.add_ssh_key ? 0 : 1
  admin_username                  = var.virtual_machine_admin_username
  admin_password                  = var.virtual_machine_admin_password
  name                            = "${var.copilot_name}-vm"
  disable_password_authentication = false
  location                        = var.location
  network_interface_ids           = [azurerm_network_interface.aviatrix_copilot_nic.id]
  resource_group_name             = var.use_existing_vnet == false ? azurerm_resource_group.aviatrix_copilot_rg[0].name : var.resource_group_name
  size                            = var.virtual_machine_size

  os_disk {
    name                 = var.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size
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

resource "azurerm_linux_virtual_machine" "aviatrix_copilot_vm_ssh" {
  count                           = var.add_ssh_key ? 1 : 0
  admin_username                  = var.virtual_machine_admin_username
  admin_password                  = var.virtual_machine_admin_password
  name                            = "${var.copilot_name}-vm"
  disable_password_authentication = false
  location                        = var.location
  network_interface_ids           = [azurerm_network_interface.aviatrix_copilot_nic.id]
  resource_group_name             = var.use_existing_vnet == false ? azurerm_resource_group.aviatrix_copilot_rg[0].name : var.resource_group_name
  size                            = var.virtual_machine_size

  os_disk {
    name                 = var.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size
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

  admin_ssh_key {
    username   = var.virtual_machine_admin_username
    public_key = local.ssh_key
  }
}

resource "azurerm_managed_disk" "default" {
  count                = var.default_data_disk_size == 0 ? 0 : 1
  name                 = "default-data-disk"
  location             = azurerm_resource_group.aviatrix_copilot_rg[0].location
  resource_group_name  = azurerm_resource_group.aviatrix_copilot_rg[0].name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.default_data_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "default" {
  count              = var.default_data_disk_size == 0 ? 0 : 1
  managed_disk_id    = azurerm_managed_disk.default[0].id
  virtual_machine_id = var.add_ssh_key ? azurerm_linux_virtual_machine.aviatrix_copilot_vm_ssh[0].id : azurerm_linux_virtual_machine.aviatrix_copilot_vm[0].id
  lun                = "0"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_att" {
  for_each           = var.additional_disks
  managed_disk_id    = each.value.managed_disk_id
  virtual_machine_id = var.add_ssh_key ? azurerm_linux_virtual_machine.aviatrix_copilot_vm_ssh[0].id : azurerm_linux_virtual_machine.aviatrix_copilot_vm[0].id
  lun                = each.value.lun
  caching            = "ReadWrite"
}
