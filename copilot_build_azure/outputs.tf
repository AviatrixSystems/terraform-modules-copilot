data "azurerm_public_ip" "public_ip" {
  name                = azurerm_public_ip.aviatrix_copilot_public_ip.name
  resource_group_name = var.use_existing_vnet == false ? azurerm_resource_group.aviatrix_copilot_rg[0].name : var.resource_group_name
}

output "public_ip" {
  value = data.azurerm_public_ip.public_ip.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.aviatrix_copilot_nic.private_ip_address
}
