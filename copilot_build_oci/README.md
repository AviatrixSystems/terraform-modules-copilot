# Aviatrix Copilot Build OCI

This module builds an Aviatrix Copilot in OCI.

### Usage:

To create an Aviatrix Copilot:

```
provider "oci" {
}

module "copilot_build_oci" {
  source           = "git@github.com:AviatrixSystems/terraform-modules-copilot/copilot_build_oci.git"
  tenancy_ocid     = "<<< tenancy id >>>"
  compartment_ocid = "<<< compartment id >>>"
  tcp_allowed_cidrs = ["<< CIDR_1 allowed for HTTPS access >>", "<< CIDR_2 allowed for HTTPS access >>", ...]
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

- **tcp_allowed_cidrs**

  Set of CIDRs allowed for HTTPS access.

- **udp_allowed_cidrs**

  Map of CIDRs allowed for UDP access. Please set port(number) and cidr(string) in each map element. Please see the example code above for example.

- **instance_shape**

  Instance shape. Default: "VM.Standard2.8".

- **vm_display_name**

  VM display name. Default: "copilot-vm".

### Outputs

- **private_ip**

  Copilot private IP.

- **public_ip**

  Copilot public IP.
