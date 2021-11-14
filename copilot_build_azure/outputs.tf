data "azurerm_public_ip" "aviatrix_copilot_public_ip_address" {
  name                = azurerm_public_ip.aviatrix_copilot_public_ip.name
  resource_group_name = azurerm_resource_group.aviatrix_copilot_rg.name

  depends_on = [
  azurerm_resource_group.aviatrix_copilot_rg]
}
output "aviatrix_copilot_public_ip_address" {
  value = data.azurerm_public_ip.aviatrix_copilot_public_ip_address.ip_address
}

output "aviatrix_copilot_private_ip_address" {
  value = azurerm_network_interface.aviatrix_copilot_nic.private_ip_address
}
