## Aviatrix - Terraform Modules Copilot - GCP Copilot Cluster Initialize

### Description

This Terraform module initializes a newly created Aviatrix Copilot Cluster. This module assumes that the controller, main copilot and copilot nodes are all deployed on GCP.

### Example of Launching Copilot Instances and Initializing the Cluster

In the following example:
1. A main copilot instance is launched using the [copilot_build_gcp](../copilot_build_gcp) module.
2. In the same network where the main copilot is, three node copilot instances are launched using the [copilot_build_gcp](../copilot_build_gcp) module.
3. The copilot cluster is initialized using the [copilot_cluster_initialize_gcp](../copilot_cluster_initialize_gcp) module.
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

provider "google" {
  project = "<< PROJECT >>"
  region  = "<< REGION >>"
  zone    = "<< ZONE >>"
}

module "main" {
  source                 = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_gcp"
  copilot_name           = "main"
  network_tags           = ["main"]
  ip_address_name        = "main-ip"
  default_data_disk_size = 50
  is_cluster             = true
  controller_public_ip   = "<< CONTROLLER PRIVATE IP >>"
  controller_private_ip  = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcp" = {
      protocol = "tcp"
      port = "443"
      cidrs = ["<< CIDR ALLOWED FOR HTTPS ACCESS>>"]
    }
    "udp1" = {
      protocol = "udp"
      port = "5000"
      cidrs = ["0.0.0.0/0"]
    }
    "udp2" = {
      protocol = "udp"
      port = "31283"
      cidrs = ["0.0.0.0/0"]
    }
  }
}

// ************
// ** Step 2 **
// ************

resource "google_compute_subnetwork" "node1_subnet" {
  name          = "node1-subnetwork"
  network       = module.main.network
  ip_cidr_range = "10.0.2.0/24"
}

resource "google_compute_subnetwork" "node2_subnet" {
  name          = "node2-subnetwork"
  network       = module.main.network
  ip_cidr_range = "10.0.3.0/24"
}

resource "google_compute_subnetwork" "node3_subnet" {
  name          = "node3-subnetwork"
  network       = module.main.network
  ip_cidr_range = "10.0.4.0/24"
}

module "node1" {
  source = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_gcp"
  use_existing_network   = true
  network                = google_compute_subnetwork.node1_subnet.network
  subnetwork             = google_compute_subnetwork.node1_subnet.self_link
  copilot_name           = "node1"
  network_tags           = ["node1"]
  ip_address_name        = "node1-ip"
  default_data_disk_name = "node1-data"
  default_data_disk_size = 50
  is_cluster             = true
  controller_public_ip   = "<< CONTROLLER PRIVATE IP >>"
  controller_private_ip  = "<< CONTROLLER PRIVATE IP >>"

  allowed_cidrs = {
    "tcpnode1" = {
      protocol = "tcp"
      port = "443"
      cidrs = ["<< CIDR ALLOWED FOR HTTPS ACCESS>>"]
    }
    "udp1node1" = {
      protocol = "udp"
      port = "5000"
      cidrs = ["0.0.0.0/0"]
    }
    "udp2node1" = {
      protocol = "udp"
      port = "31283"
      cidrs = ["0.0.0.0/0"]
    }
  }
}

module "node2" {
  source                 = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_gcp"
  use_existing_network   = true
  network                = google_compute_subnetwork.node1_subnet.network
  subnetwork             = google_compute_subnetwork.node1_subnet.self_link
  copilot_name           = "node2"
  network_tags           = ["node2"]
  ip_address_name        = "node2-ip"
  default_data_disk_name = "node2-data"
  default_data_disk_size = 50
  is_cluster             = true
  controller_public_ip   = "<< CONTROLLER PRIVATE IP >>"
  controller_private_ip  = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcpnode2" = {
      protocol = "tcp"
      port = "443"
      cidrs = ["<< CIDR ALLOWED FOR HTTPS ACCESS>>"]
    }
    "udp1node2" = {
      protocol = "udp"
      port = "5000"
      cidrs = ["0.0.0.0/0"]
    }
    "udp2node2" = {
      protocol = "udp"
      port = "31283"
      cidrs = ["0.0.0.0/0"]
    }
  }
}

module "node3" {
  source = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_gcp"
  use_existing_network   = true
  network                = google_compute_subnetwork.node1_subnet.network
  subnetwork             = google_compute_subnetwork.node1_subnet.self_link
  copilot_name           = "node3"
  network_tags           = ["node3"]
  ip_address_name        = "node3-ip"
  default_data_disk_name = "node3-data"
  default_data_disk_size = 50
  is_cluster             = true
  controller_public_ip   = "<< CONTROLLER PRIVATE IP >>"
  controller_private_ip  = "<< CONTROLLER PRIVATE IP >>"
  
  allowed_cidrs = {
    "tcpnode3" = {
      protocol = "tcp"
      port = "443"
      cidrs = ["<< CIDR ALLOWED FOR HTTPS ACCESS>>"]
    }
    "udp1node3" = {
      protocol = "udp"
      port = "5000"
      cidrs = ["0.0.0.0/0"]
    }
    "udp2node3" = {
      protocol = "udp"
      port = "31283"
      cidrs = ["0.0.0.0/0"]
    }
  }
}

// ************
// ** Step 3 **
// ************

module "init" {
  source                      = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_cluster_initialize_gcp"
  project_id                  = "<< PROJECT ID >>"
  service_account_private_key = "<< SERVICE ACCOUNT PRIVATE KEY PATH >>"
  controller_public_ip        = "<< CONTROLLER PUBLIC IP >>"
  controller_private_ip       = "<< CONTROLLER PRIVATE IP >>"
  controller_username         = "<< CONTROLLER USERNAME >>"
  controller_password         = "<< CONTROLLER PASSWORD >>"
  controller_network_tag      = "controller"
  main_copilot_public_ip      = module.main.public_ip
  main_copilot_private_ip     = module.main.private_ip
  main_copilot_username       = "<< CONTROLLER USERNAME >>"
  main_copilot_password       = "<< CONTROLLER PASSWORD >>"
  main_copilot_network_tag    = "main"
  node_copilot_public_ips     = [module.node1.public_ip, module.node2.public_ip, module.node3.public_ip]
  node_copilot_private_ips    = [module.node1.private_ip, module.node2.private_ip, module.node3.private_ip]
  node_copilot_usernames      = ["<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>", "<< CONTROLLER USERNAME >>"]
  node_copilot_passwords      = ["<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>", "<< CONTROLLER PASSWORD >>"]
  node_copilot_names          = ["node1", "node2", "node3"]
  node_copilot_network_tags   = ["ndoe1", "node2", "node3"]            
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

- **project_id**
  Project ID.

- **service_account_private_key**
  Service account private key path.

- **controller_public_ip**
  Controller public IP. Default: "0.0.0.0".

- **controller_private_ip**
  Controller private IP.

- **controller_username**
  Controller username.

- **controller_password**
  Controller password.

- **controller_network_tag**
  Copilot net work tag.

- **main_copilot_public_ip**
  Main copilot public IP. Default: "0.0.0.0".

- **main_copilot_private_ip**
  Main copilot private IP.

- **main_copilot_username**
  Main copilot username.

- **main_copilot_password**
  Main copilot password.

- **main_copilot_network_tag**
  Main copilot net work tag.

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

- **node_copilot_net_work_tags**
  List of node copilot network tags.
