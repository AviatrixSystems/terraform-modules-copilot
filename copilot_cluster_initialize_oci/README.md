## Aviatrix - Terraform Modules Copilot - OCI Copilot Cluster Initialize

### Description

This Terraform module initializes a newly created Aviatrix Copilot Cluster. This module assumes that the controller, main copilot and copilot nodes are all deployed on OCI.

### Example of Launching Copilot Instances and Initializing the Cluster

In the following example:
1. A main copilot instance is launched using the [copilot_build_oci](../copilot_build_oci) module.
2. In the same network where the main copilot is, three node copilot instances are launched using the [copilot_build_oci](../copilot_build_oci) module.
3. The copilot cluster is initialized using the [copilot_cluster_initialize_oci](../copilot_cluster_initialize_oci) module.
4. Some settings in the controller are configured using the [Aviatrix Terraform provider](https://registry.terraform.io/providers/AviatrixSystems/aviatrix/2.23.0).

> **NOTE:** 
> 1. After the cluster has been successfully initialized, the following settings need to be configured in the Aviatrix controller. This is the reason for the step 4 above.
> * Enable syslog configuration for main copilot
> * Enable netflow configuration for main copilot
> * Enable copilot security group management in controller
> 2. After deployment, the main copilot ports 31283 and 5000 will be open for any IP (0.0.0.0/0). It is strongly recommended removing the 0.0.0.0 entry from the CoPilot security group for these ports and add entries for all of your gateway IP addresses.

``` hcl
// ************
// ** Step 1 **
// ************

provider "oci" {
  tenancy_ocid     = "<< TENANCY OCID >>"
  user_ocid        = "<< USER OCID >>"
  fingerprint      = "<< FINGERPRINT >>"
  private_key_path = "<< PRIVATE KEY PATH >>"
  region           = "<< REGION >>"
}

module "main" {
  source                     = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_oci"
  tenancy_ocid               = "<< TENANCY ID >>"
  compartment_ocid           = "<< COMPARTMENT ID >>"
  availability_domain_number = "<< AVAILABILITY DOMAIN NUMBER >>"
  https_allowed_cidrs        = ["<< CIDR ALLOWED FOR HTTPS ACCESS >>"]
  default_data_volume_size   = 50
  
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

// ************
// ** Step 2 **
// ************

resource "oci_core_subnet" "node1_subnet" {
  availability_domain = module.main.availability_domain
  cidr_block          = "10.0.2.0/24"
  display_name        = "node1_subnet"
  dns_label           = "node1_dns"
  security_list_ids   = [module.main.security_list_id]
  compartment_id      = << COMPARTMENT ID >>""
  vcn_id              = module.main.vcn_id
  route_table_id      = module.main.route_table_id 
  dhcp_options_id     = module.main.dhcp_options_id
}

resource "oci_core_subnet" "node2_subnet" {
  availability_domain = module.main.availability_domain
  cidr_block          = "10.0.3.0/24"
  display_name        = "node2_subnet"
  dns_label           = "node2_dns"
  security_list_ids   = [module.main.security_list_id]
  compartment_id      = << COMPARTMENT ID >>""
  vcn_id              = module.main.vcn_id
  route_table_id      = module.main.route_table_id 
  dhcp_options_id     = module.main.dhcp_options_id
}

resource "oci_core_subnet" "node3_subnet" {
  availability_domain = module.main.availability_domain
  cidr_block          = "10.0.4.0/24"
  display_name        = "node3_subnet"
  dns_label           = "node3_dns"
  security_list_ids   = [module.main.security_list_id]
  compartment_id      = << COMPARTMENT ID >>""
  vcn_id              = module.main.vcn_id
  route_table_id      = module.main.route_table_id 
  dhcp_options_id     = module.main.dhcp_options_id
}

module "node1" {
  source                     = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_oci"
  tenancy_ocid               = "<< TENANCY ID >>"
  compartment_ocid           = "<< COMPARTMENT ID >>"
  availability_domain_number = "<< AVAILABILITY DOMAIN NUMBER >>"
  use_existing_vcn           = true
  vcn_id                     = module.main.vcn_id
  subnet_id                  = oci_core_subnet.node1_subnet.id
  https_allowed_cidrs        = ["<< CIDR ALLOWED FOR HTTPS ACCESS >>"]
  default_data_volume_size   = 50
  
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

module "node2" {
  source                     = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_oci"
  tenancy_ocid               = "<< TENANCY ID >>"
  compartment_ocid           = "<< COMPARTMENT ID >>"
  availability_domain_number = "<< AVAILABILITY DOMAIN NUMBER >>"
  use_existing_vcn           = true
  vcn_id                     = module.main.vcn_id
  subnet_id                  = oci_core_subnet.node2_subnet.id
  https_allowed_cidrs        = ["<< CIDR ALLOWED FOR HTTPS ACCESS >>"]
  default_data_volume_size   = 50
  
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

module "node3" {
  source                     = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_oci"
  tenancy_ocid               = "<< TENANCY ID >>"
  compartment_ocid           = "<< COMPARTMENT ID >>"
  availability_domain_number = "<< AVAILABILITY DOMAIN NUMBER >>"
  use_existing_vcn           = true
  vcn_id                     = module.main.vcn_id
  subnet_id                  = oci_core_subnet.node3_subnet.id
  https_allowed_cidrs        = ["<< CIDR ALLOWED FOR HTTPS ACCESS >>"]
  default_data_volume_size   = 50
  
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

// ************
// ** Step 3 **
// ************

module "init" {
  source                   = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_cluster_initialize_oci"
  user_id                  = "<< USER ID >>"
  tenancy_id               = "<< TENANCY ID >>"
  fingerprint              = "<< FINGERPRINT >>"
  key_file                 = "<< KEY FILE PATH >>"
  region                   = "<< REGION >>"
  controller_public_ip     = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip    = "<< CONTROLLER PRIVATE IP >>"
  controller_username      = "<< CONTROLLER USERNAME >>"
  controller_password      = "<< CONTROLLER PASSWORD >>"
  controller_nsg_id        = "<< CONTROLLER NSG ID >>"
  main_copilot_public_ip   = module.main.public_ip
  main_copilot_private_ip  = module.main.private_ip
  main_copilot_username    = "<< CONTROLLER USERNAME >>"
  main_copilot_password    = "<< CONTROLLER PASSWORD >>"
  main_copilot_nsg_id      = module.main.nsg_id
  node_copilot_public_ips  = [module.node1.public_ip, module.node2.public_ip, module.node3.public_ip]
  node_copilot_private_ips = [module.node1.private_ip, module.node2.private_ip, module.node3.private_ip]
  node_copilot_usernames   = ["<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>"]
  node_copilot_passwords   = ["<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>"]
  node_copilot_names       = ["node1", "node2", "node3"]
  node_copilot_nsg_ids     = [module.node1.nsg_id, module.node2.nsg_id, module.node3.nsg_id]
}

output "main_public_ip" {
  value = module.main.public_ip
}
output "main_private_ip" {
  value = module.main.private_ip
}
output "node1_public_ip" {
  value = module.node1.public_ip
}
output "node1_private_ip" {
  value = module.node1.private_ip
}
output "node2_public_ip" {
  value = module.node2.public_ip
}
output "node2_private_ip" {
  value = module.node2.private_ip
}
output "node3_public_ip" {
  value = module.node3.public_ip
}
output "node3_private_ip" {
  value = module.node3.private_ip
}

// ************
// ** Step 4 **
// ************

terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "2.23.0" // version 2.23+ is required
    }
  }
}

provider "aviatrix" {
  username      = "<< CONTROLLER USERNAME >>"
  password      = "<< CONTROLLER PASSWORD >>"
  controller_ip = "<< CONTROLLER PUBLIC IP >>"
}

resource "aviatrix_remote_syslog" "copilot_remote_syslog" {
  index    = 9
  name     = "example"
  server   = module.main.public_ip
  port     = 5000
  protocol = "UDP"
}

resource "aviatrix_netflow_agent" "copilot_netflow_agent" {
  server_ip = module.main.public_ip
  port      = 31283
}

resource "aviatrix_copilot_security_group_management_config" "copilot_sg_mgmt" {
  cloud_type                               = 1
  account_name                             = "<< ACCESS ACCOUNT NAME >>"
  region                                   = module.main.region
  vpc_id                                   = module.main.vpc_id
  instance_id                              = module.main.ec2-info[0].id
  enable_copilot_security_group_management = true
}
```

### Variables

        "user_id": user_id,
        "tenancy_id": tenancy_id,
        "fingerprint": fingerprint,
        "key_file": key_file,
        "region": region,

- **user_id**
  User ID.

- **tenancy_id**
  Tenancy ID.

- **fingerprint**
  Fingerprint.

- **key_file**
  Key file path.

- **region**
  Region.

- **controller_public_ip**
  Controller public IP. Default: "0.0.0.0".

- **controller_private_ip**
  Controller private IP.

- **controller_username**
  Controller username.

- **controller_password**
  Controller password.

- **controller_nsg_id**
  Controller nsg ID.

- **main_copilot_public_ip**
  Main copilot public IP. Default: "0.0.0.0".

- **main_copilot_private_ip**
  Main copilot private IP.

- **main_copilot_username**
  Main copilot username.

- **main_copilot_password**
  Main copilot password.

- **main_copilot_nsg_id**
  Main copilot nsg ID.

- **node_copilot_public_ips**
  List of node copilot public IPs. Default: ["0.0.0.0"].

- **node_copilot_private_ips**
  List of node copilot private IPs.

- **node_copilot_usernames**
  List of node copilot usernames.

- **node_copilot_passwords**
  List of node copilot passwords.

- **node_copilot_names**
  List of node copilot names.

- **node_copilot_nsg_ids**
  List of node copilot nsg IDs.
