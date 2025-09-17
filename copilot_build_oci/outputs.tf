output "availability_domain" {
  value = data.oci_identity_availability_domain.ad.name
}

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

output "vcn_id" {
  value = var.use_existing_vcn ? var.vcn_id : oci_core_vcn.copilot_vcn[0].id
}

data "oci_core_vcn" "vcn" {
  vcn_id = var.use_existing_vcn ? var.vcn_id : oci_core_vcn.copilot_vcn[0].id
}

output "security_list_id" {
  value = data.oci_core_vcn.vcn.default_security_list_id
}

output "dhcp_options_id" {
  value = data.oci_core_vcn.vcn.default_dhcp_options_id
}

data "oci_core_route_tables" "route_table" {
  compartment_id = var.compartment_ocid
  display_name   = var.routetable_display_name
}

output "route_table_id" {
  value = data.oci_core_route_tables.route_table.id
}
