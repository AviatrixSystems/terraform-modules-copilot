data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

resource "oci_core_vcn" "copilot_vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
}

resource "oci_core_subnet" "copilot_subnet" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.subnet_cidr_block
  display_name        = var.subnet_display_name
  dns_label           = var.subnet_dns_label
  security_list_ids   = [oci_core_vcn.copilot_vcn.default_security_list_id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.copilot_vcn.id
  route_table_id      = oci_core_route_table.copilot_rt.id
  dhcp_options_id     = oci_core_vcn.copilot_vcn.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "copilot_igw" {
  compartment_id = var.compartment_ocid
  display_name   = var.igw_display_name
  vcn_id         = oci_core_vcn.copilot_vcn.id
}

resource "oci_core_route_table" "copilot_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.copilot_vcn.id
  display_name   = var.routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.copilot_igw.id
  }
}

resource "oci_core_network_security_group" "nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.copilot_vcn.id
  display_name   = var.nsg_display_name
}

resource "oci_core_network_security_group_security_rule" "rule_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id

  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_tcp" {
  for_each = var.tcp_allowed_cidrs
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
  for_each = var.udp_allowed_cidrs
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

data "oci_core_app_catalog_listing_resource_versions" "test_app_catalog_listing_resource_versions" {
  listing_id = "ocid1.appcataloglisting.oc1..aaaaaaaabr37btdgmub7gohpxtzle6ff2vhig46tuc7qpsq2bkmlznzbyheq"
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "test_app_catalog_listing_resource_version_agreement" {
  listing_id               = data.oci_core_app_catalog_listing_resource_versions.test_app_catalog_listing_resource_versions.app_catalog_listing_resource_versions[0]["listing_id"]
  listing_resource_version = data.oci_core_app_catalog_listing_resource_versions.test_app_catalog_listing_resource_versions.app_catalog_listing_resource_versions[0]["listing_resource_version"]
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
  listing_id = oci_core_app_catalog_subscription.test_app_catalog_subscription.listing_id

  filter {
    name   = "listing_resource_version"
    values = [oci_core_app_catalog_subscription.test_app_catalog_subscription.listing_resource_version]
  }
}

resource "oci_core_instance" "copilot_vm" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_display_name
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.copilot_subnet.id
    display_name     = var.vm_display_name
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.nsg.id]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_app_catalog_subscriptions.test_app_catalog_subscriptions.app_catalog_subscriptions[0]["listing_resource_id"]
  }
}
