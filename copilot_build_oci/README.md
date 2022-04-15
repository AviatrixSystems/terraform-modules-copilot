# Aviatrix Copilot Build OCI

This module builds an Aviatrix Copilot in OCI.

### Usage:

To create an Aviatrix Copilot:

```
provider "oci" {
}

module "copilot_build_oci" {
  source                     = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_oci"
  tenancy_ocid               = "<<< tenancy id >>>"
  compartment_ocid           = "<<< compartment id >>>"
  availability_domain_number = "<<< availability domain number >>>"
  https_allowed_cidrs        = ["<< CIDR_1 allowed for HTTPS access >>", "<< CIDR_2 allowed for HTTPS access >>", ...]
  
  udp_allowed_cidrs = {
    "udp1" = {
      port     = 5000
      cidr     = "0.0.0.0/0"
    }
    "udp2" = {
      port     = 31283
      cidr     = "0.0.0.0/0"
    }
  }
  
  additional_volumes = {
    "one" = {
      attachment_type = "<< attachment type 1 >>"
      volume_id = "<< volume id 1 >>"
    }
    "two" = {
      attachment_type = "<< attachment type 2 >>"
      volume_id = "<< volume id 2 >>"
    }
  }
}

output "copilot_public_ip" {
value = module.copilot_build_oci.public_ip
}

output "copilot_private_ip" {
value = module.copilot_build_oci.private_ip
}
```

### Variables

- **tenancy_ocid**

  Tenancy ID.

- **compartment_ocid**

  Compartment ID.

- **availability_domain_number**

  Availability domain number.

> **NOTE:** If **use_existing_vcn** is set to true, **vcn_id** and **subnet_id** are required. Make sure that resources `oci_core_vcn`, `oci_core_subnet`, `oci_core_internet_gateway` and `oci_core_route_table` are configured properly.

- **use_existing_vcn**

  Flag to indicate whether to use an existing VCN. Default: false.

- **vcn_id**

  VCN ID. Only required when use_existing_vcn is true. Default: "".

- **subnet_id**

  Subnet ID. Only required when use_existing_vcn is true. Default: "".

- **vcn_cidr_block**

  VCN CIDR. Default: "10.1.0.0/16".

- **vcn_display_name**

  VCN display name. Default: "copilot-vcn".

- **vcn_dns_label**

  VCN DNS label. Default: "aviatrix".

- **subnet_cidr_block**

  Subnet CIDR. Default: "10.1.20.0/24".

- **subnet_display_name**

  Subnet display name. Default: "copilot-subnet".

- **subnet_dns_label**

  Subnet DNS label. Default: "management".

- **igw_display_name**

  IGW display name. Default: "copilot-igw".

- **routetable_display_name**

  Route table display name. Default: "copilot-rt"

- **nsg_display_name**

  Network security group display name. Default: "copilot-nsg".

- **https_allowed_cidrs**

  Set of CIDRs allowed for HTTPS access.

- **udp_allowed_cidrs**

  Map of CIDRs allowed for UDP access. Please set port(number) and cidr(string) in each map element. Please see the example code above for example.

- **ssh_allowed_cidrs**

  Set of CIDRs allowed for SSH access.

- **instance_shape**

  Instance shape. Default: "VM.Standard2.8".

- **boot_volume_size**

  Boot volume size for copilot. The minimum boot volume size is 50G. Default: 50.

- **vm_display_name**

  VM display name. Default: "copilot-vm".

- **copilot_version**

  Copilot version. Default: "1.6.1".

> **NOTE:** If **use_existing_ssh_key** is set to false, new keys will be generated. If **use_existing_keypair** is set to true, either **ssh_public_key_file_path** or **ssh_public_key_file_content** must be configured.

- **use_existing_ssh_key**

  Flag to indicate whether to use an existing ssh key. Default: false.

- **ssh_public_key_file_path**

  File path to the SSH public key. If not set, defaults to "".

- **ssh_public_key_file_content**

  File content of the SSH public key. If not set, defaults to "".

> **NOTE:** Please make sure the additional volumes and the copilot vm are in the same availability domain.

- **default_data_volume_size**

  Size of default data volume. If not set, no default data volume will be created. Default: 0.

- **additional_volumes**

  Map of additional volumes that will be attached to the copilot instance. Please set attachment_type(string) and volume_id(string) in each map element. Please see the example code above for example.

### Outputs

- **private_ip**

  Copilot private IP.

- **public_ip**

  Copilot public IP.
