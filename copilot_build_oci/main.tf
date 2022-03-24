data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain_number
}

resource "oci_core_vcn" "copilot_vcn" {
  count          = var.use_existing_vcn == false ? 1 : 0
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
}

resource "oci_core_subnet" "copilot_subnet" {
  count               = var.use_existing_vcn == false ? 1 : 0
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.subnet_cidr_block
  display_name        = var.subnet_display_name
  dns_label           = var.subnet_dns_label
  security_list_ids   = [oci_core_vcn.copilot_vcn[0].default_security_list_id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.copilot_vcn[0].id
  route_table_id      = oci_core_route_table.copilot_rt[0].id
  dhcp_options_id     = oci_core_vcn.copilot_vcn[0].default_dhcp_options_id
}

resource "oci_core_internet_gateway" "copilot_igw" {
  count          = var.use_existing_vcn == false ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = var.igw_display_name
  vcn_id         = oci_core_vcn.copilot_vcn[0].id
}

resource "oci_core_route_table" "copilot_rt" {
  count          = var.use_existing_vcn == false ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.copilot_vcn[0].id
  display_name   = var.routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.copilot_igw[0].id
  }
}

resource "oci_core_network_security_group" "nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.use_existing_vcn == false ? oci_core_vcn.copilot_vcn[0].id : var.vcn_id
  display_name   = var.nsg_display_name
}

resource "oci_core_network_security_group_security_rule" "rule_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_https" {
  for_each                  = var.https_allowed_cidrs
  network_security_group_id = oci_core_network_security_group.nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = each.value
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_udp" {
  for_each                  = var.udp_allowed_cidrs
  network_security_group_id = oci_core_network_security_group.nsg.id
  protocol                  = "17"
  direction                 = "INGRESS"
  source                    = each.value["cidr"]
  stateless                 = false

  udp_options {
    destination_port_range {
      min = each.value["port"]
      max = each.value["port"]
    }
  }
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_ssh" {
  for_each                  = var.ssh_allowed_cidrs
  network_security_group_id = oci_core_network_security_group.nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = each.value
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

data "oci_core_app_catalog_listing_resource_versions" "test_app_catalog_listing_resource_versions" {
  listing_id = "ocid1.appcataloglisting.oc1..aaaaaaaabr37btdgmub7gohpxtzle6ff2vhig46tuc7qpsq2bkmlznzbyheq"
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "test_app_catalog_listing_resource_version_agreement" {
  listing_id               = "ocid1.appcataloglisting.oc1..aaaaaaaabr37btdgmub7gohpxtzle6ff2vhig46tuc7qpsq2bkmlznzbyheq"
  listing_resource_version = var.copilot_version
}

resource "oci_core_app_catalog_subscription" "test_app_catalog_subscription" {
  compartment_id           = var.compartment_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.test_app_catalog_listing_resource_version_agreement.eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.test_app_catalog_listing_resource_version_agreement.listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.test_app_catalog_listing_resource_version_agreement.listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.test_app_catalog_listing_resource_version_agreement.oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.test_app_catalog_listing_resource_version_agreement.signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.test_app_catalog_listing_resource_version_agreement.time_retrieved

  timeouts {
    create = "20m"
  }
}

data "oci_core_app_catalog_subscriptions" "test_app_catalog_subscriptions" {
  compartment_id = var.compartment_ocid
  listing_id     = oci_core_app_catalog_subscription.test_app_catalog_subscription.listing_id

  filter {
    name   = "listing_resource_version"
    values = [oci_core_app_catalog_subscription.test_app_catalog_subscription.listing_resource_version]
  }
}

resource "tls_private_key" "key_pair_material" {
  count     = var.use_existing_ssh_key == false ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "oci_core_instance" "copilot_vm" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_display_name
  shape               = var.instance_shape
  metadata = {
    ssh_authorized_keys = local.ssh_key
  }

  create_vnic_details {
    subnet_id        = var.use_existing_vcn == false ? oci_core_subnet.copilot_subnet[0].id : var.subnet_id
    display_name     = var.vm_display_name
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.nsg.id]
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_app_catalog_subscriptions.test_app_catalog_subscriptions.app_catalog_subscriptions[0]["listing_resource_id"]
    boot_volume_size_in_gbs = var.boot_volume_size
  }
}

resource "oci_core_volume" "default" {
  count               = var.default_data_volume_size == 0 ? 0 : 1
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.ad.name
  size_in_gbs         = var.default_data_volume_size
}

resource "oci_core_volume_attachment" "default" {
  count           = var.default_data_volume_size == 0 ? 0 : 1
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.copilot_vm.id
  volume_id       = oci_core_volume.default[0].id
}

resource "oci_core_volume_attachment" "test_volume_attachment" {
  for_each        = var.additional_volumes
  instance_id     = oci_core_instance.copilot_vm.id
  attachment_type = each.value.attachment_type
  volume_id       = each.value.volume_id
}
