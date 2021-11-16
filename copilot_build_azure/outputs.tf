data "azurerm_public_ip" "public_ip" {
  name                = azurerm_public_ip.aviatrix_copilot_public_ip.name
  resource_group_name = azurerm_resource_group.aviatrix_copilot_rg.name

  depends_on = [
  azurerm_resource_group.aviatrix_copilot_rg]
}
output "public_ip" {
  value = data.azurerm_public_ip.public_ip.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.aviatrix_copilot_nic.private_ip_address
}
