output "public_ip" {
  value = oci_core_instance.copilot_vm.public_ip
}

output "private_ip" {
  value = oci_core_instance.copilot_vm.private_ip
}

output "instance_id" {
  value = oci_core_instance.copilot_vm.id
}

output "nsg_id" {
  value = oci_core_network_security_group.nsg.id
}

output "security_list_id" {
  value = oci_core_vcn.copilot_vcn[0].default_security_list_id
}

output "availability_domain" {
  value = data.oci_identity_availability_domain.ad.name
}

output "vcn_id" {
  value = oci_core_vcn.copilot_vcn.id
}

output "route_table_id" {
  value = oci_core_route_table.copilot_rt[0].id
}

output "dhcp_options_id" {
  value = oci_core_vcn.copilot_vcn[0].default_dhcp_options_id
}
